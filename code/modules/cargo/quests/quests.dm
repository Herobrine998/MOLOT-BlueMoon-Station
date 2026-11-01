// Позиции заказа не меняются при проверке: одна посылка оценивается для нескольких клиентов.
/datum/cargo_quest
	var/label
	var/target
	var/kind = CARGO_QUEST_ITEM
	var/amount = 1
	var/reward = 0
	var/image

/datum/cargo_quest/New(target_path, list/entry, goal_kind)
	..()
	target = target_path
	label = entry[1]
	amount = entry[2]
	reward = entry[3]
	kind = goal_kind
	var/atom/icon_target = target
	switch(kind)
		if(CARGO_QUEST_REAGENT)
			icon_target = /obj/item/reagent_containers/glass/beaker/large
		if(CARGO_QUEST_PLANT_GENE)
			icon_target = /obj/item/disk/plantgene
		if(CARGO_QUEST_MUTATION)
			icon_target = /obj/item/dnainjector
		if(CARGO_QUEST_VIRUS)
			icon_target = /obj/item/reagent_containers/glass/bottle/vial
		if(CARGO_QUEST_TECH_NODE)
			icon_target = /obj/item/disk/tech_disk
	image = SScargo_quests.get_icon(icon_target)

/datum/cargo_quest/proc/description()
	var/unit = kind == CARGO_QUEST_REAGENT ? " ед." : " шт."
	var/requirements = kind == CARGO_QUEST_SEED ? " (потенция не ниже 100)" : ""
	return "[label]: [amount][unit][requirements]"

/datum/cargo_quest/proc/item_amount(obj/item/item)
	if(item.flags_1 & HOLOGRAM_1)
		return 0
	switch(kind)
		if(CARGO_QUEST_ITEM)
			if(item.type != target)
				return 0
			if(istype(item, /obj/item/stack))
				var/obj/item/stack/stack = item
				return stack.amount
			return 1
		if(CARGO_QUEST_REAGENT)
			if(!istype(item, /obj/item/reagent_containers))
				return 0
			return item.reagents?.get_reagent_amount(target) || 0
		if(CARGO_QUEST_SEED)
			if(item.type != target)
				return 0
			var/obj/item/seeds/seed = item
			return seed.potency >= 100
		if(CARGO_QUEST_PLANT_GENE)
			if(!istype(item, /obj/item/disk/plantgene))
				return 0
			var/obj/item/disk/plantgene/disk = item
			return disk.gene?.type == target
		if(CARGO_QUEST_MUTATION)
			if(!istype(item, /obj/item/dnainjector))
				return 0
			var/obj/item/dnainjector/injector = item
			if(injector.used)
				return 0
			// Генетическая консоль записывает экземпляры мутаций, готовые инъекторы — пути типов.
			for(var/mutation in injector.add_mutations)
				if(mutation == target || istype(mutation, target))
					return 1
			return 0
		if(CARGO_QUEST_VIRUS)
			if(!istype(item, /obj/item/reagent_containers) || !item.reagents)
				return 0
			var/datum/reagent/blood/blood = item.reagents.has_reagent(/datum/reagent/blood, 10)
			if(!blood)
				return 0
			for(var/datum/disease/advance/disease in blood.get_diseases())
				for(var/datum/symptom/symptom in disease.symptoms)
					if(symptom.type == target)
						return 1
		if(CARGO_QUEST_TECH_NODE)
			if(!istype(item, /obj/item/disk/tech_disk))
				return 0
			var/obj/item/disk/tech_disk/disk = item
			var/datum/techweb_node/node = target
			return disk.stored_research?.researched_nodes[initial(node.id)] == TRUE
	return 0

/datum/cargo_quests_storage
	var/list/current_quests = list()
	var/datum/quest_customer/customer
	var/department
	var/tier = 1
	var/active = FALSE
	var/can_reroll = TRUE
	var/deadline
	var/fast_deadline
	var/expiry_timer
	var/time_add_count = 0
	var/idname = "Не указан"
	var/idrank = "Не указана"
	var/order_time
	var/base_reward = 0
	var/priority_multiplier = 1
	var/list/interface_items = list()

/datum/cargo_quests_storage/Destroy()
	if(expiry_timer)
		deltimer(expiry_timer)
		expiry_timer = null
	SScargo_quests.quest_storages -= src
	QDEL_LIST(current_quests)
	interface_items.Cut()
	customer = null
	return ..()

/datum/cargo_quests_storage/proc/generate(datum/quest_customer/new_customer, new_tier)
	customer = new_customer
	tier = new_tier
	var/list/departments = SScargo_quests.catalog["[tier]"]
	department = customer.group_name == CARGO_QUEST_PLASMA ? CARGO_QUEST_MINING : pick(departments)
	var/list/choices = departments[department]
	if(customer.group_name == CARGO_QUEST_PLASMA)
		var/datum/cargo_quest_catalog/plasma_catalog = SScargo_quests.plasma_catalog
		var/path = /obj/item/stack/sheet/mineral/plasma
		var/list/entry = plasma_catalog.targets[path]
		current_quests += new /datum/cargo_quest(path, entry, CARGO_QUEST_ITEM)
		base_reward = entry[3]
	else
		// Копируем только небольшой индекс выбранного отдела, общий каталог остаётся неизменным.
		var/list/available = choices.Copy()
		var/count = rand(1, min(3, length(available)))
		for(var/i in 1 to count)
			var/path = pick_n_take(available)
			var/datum/cargo_quest_catalog/category = choices[path]
			var/list/entry = category.targets[path]
			current_quests += new /datum/cargo_quest(path, entry, category.kind)
			base_reward += entry[3]
	for(var/datum/cargo_quest/goal as anything in current_quests)
		interface_items += list(list("desc" = goal.description(), "image" = goal.image))
	var/static/list/minutes_min = list(15, 20, 30, 30)
	var/static/list/minutes_max = list(25, 30, 40, 60)
	var/duration = rand(minutes_min[tier], minutes_max[tier]) MINUTES
	deadline = world.time + duration
	fast_deadline = world.time + duration * 0.4
	schedule_expiry()

/datum/cargo_quests_storage/proc/schedule_expiry()
	if(expiry_timer)
		deltimer(expiry_timer)
	expiry_timer = addtimer(CALLBACK(src, PROC_REF(expire)), max(1, deadline - world.time), TIMER_STOPPABLE)

/datum/cargo_quests_storage/proc/expire()
	expiry_timer = null
	SScargo_quests.replace_quest(src, completed = FALSE)

/datum/cargo_quests_storage/proc/activate(mob/user)
	if(active || world.time >= deadline)
		return FALSE
	active = TRUE
	idname = user.real_name
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		idname = human.get_authentification_name()
		idrank = human.get_assignment(hand_first = TRUE)
	else if(issilicon(user))
		idrank = isAI(user) ? "ИИ" : "Киборг"
	order_time = STATION_TIME_TIMESTAMP("hh:mm:ss", world.time)
	deadline += CARGO_QUEST_EXTENSION
	if(fast_deadline > world.time)
		fast_deadline = max(fast_deadline, world.time + 2 MINUTES)
	schedule_expiry()
	return TRUE

/datum/cargo_quests_storage/proc/add_time()
	if(!active || time_add_count >= CARGO_QUEST_MAX_EXTENSIONS || world.time >= deadline)
		return FALSE
	time_add_count++
	deadline += CARGO_QUEST_EXTENSION
	schedule_expiry()
	return TRUE

/datum/cargo_quests_storage/proc/reward(complete = TRUE)
	var/static/list/tier_multipliers = list(1, 1.25, 1.5, 2)
	var/value = base_reward * tier_multipliers[tier] * customer.reward_multiplier * priority_multiplier * SSeconomy.bounty_modifier
	if(complete)
		value *= 1 + 0.1 * (length(current_quests) - 1)
	return round(value)

// Возвращает независимую оценку посылки, не расходуя ни предметы, ни прогресс других заказов.
/datum/cargo_quests_storage/proc/evaluate(obj/structure/big_delivery/delivery, obj/structure/closet/crate/crate)
	var/list/quantities = list()
	var/extra_items = 0
	var/matched_items = 0
	for(var/atom/movable/content in crate.contents)
		var/matched = FALSE
		if(isitem(content))
			for(var/datum/cargo_quest/goal as anything in current_quests)
				if(quantities[goal] >= goal.amount)
					continue
				var/quantity = goal.item_amount(content)
				if(quantity <= 0)
					continue
				quantities[goal] += quantity
				matched = TRUE
				matched_items++
				break
		if(!matched)
			extra_items++
	if(!matched_items)
		return
	var/completed_goals = 0
	var/completed_reward = 0
	for(var/datum/cargo_quest/goal as anything in current_quests)
		if(quantities[goal] >= goal.amount)
			completed_goals++
			completed_reward += goal.reward
	var/complete = completed_goals == length(current_quests)
	var/full_reward = reward(complete)
	var/value = full_reward * completed_reward / base_reward
	var/wrong_recipient = delivery.cargo_recipient != customer.departament_name
	if(wrong_recipient)
		value -= full_reward * 0.2
	value -= full_reward * (0.3 * extra_items + 0.1 * time_add_count)
	var/quick = complete && world.time < fast_deadline
	if(quick)
		value += full_reward * 0.4
	return list(
		"reward" = max(0, round(value)),
		"complete" = complete,
		"missing" = length(current_quests) - completed_goals,
		"extra" = extra_items,
		"wrong_recipient" = wrong_recipient,
		"quick" = quick,
	)

/datum/cargo_quests_storage/proc/printout(list/result, completed)
	var/list/lines = list("<h2>[islist(result) || !isnull(completed) ? "Отчёт о поставке" : "Запрос на поставку"]</h2>")
	lines += "Заказчик: [html_encode(customer.departament_name)]<br>Отдел: [department]<br>Тир: [tier]<br>"
	lines += "Принял: [html_encode(idname)] — [html_encode(idrank)]<br>Время приёма: [order_time || "Не принят"]<hr>"
	for(var/datum/cargo_quest/goal as anything in current_quests)
		lines += "[goal.description()]<br>"
	lines += "<hr>Награда за полный заказ: [reward()] кр.<br>"
	if(result)
		lines += "Отсутствует позиций: [result["missing"]]. Лишних предметов: [result["extra"]].<br>"
		if(result["wrong_recipient"])
			lines += "Неверный заказчик: −20%.<br>"
		if(result["extra"])
			lines += "Лишние предметы: −[result["extra"] * 30]%.<br>"
		if(result["missing"])
			lines += "Бонус за количество позиций не применяется к неполной поставке.<br>"
		if(result["quick"])
			lines += "Быстрая доставка: +40%.<br>"
		if(time_add_count)
			lines += "Продление срока: −[time_add_count * 10]%.<br>"
		lines += "<b>Выплачено: [result["reward"]] кр.</b><br>"
		if(customer.group_name == CARGO_QUEST_CORPORATION)
			lines += "Распределение: 60% — карго, 25% — станция, 15% — отдел-исполнитель.<br>"
	else if(!isnull(completed) && !completed)
		lines += "Срок запроса истёк. Выплата: 0 кр.<br>"
	else
		lines += "Упакуйте ящик упаковочной бумагой. Выберите заказчика через Alt+ЛКМ по маркировщику и отметьте им посылку.<br>"
		lines += "Один ящик выполняет один принятый запрос. Учитывается только непосредственное содержимое ящика.<br>"
		lines += "Бонус за быструю доставку: +40%. Неверный заказчик: −20%. Лишний предмет: −30%. Продление: −10%.<br>"
		lines += "Срок: ещё [max(0, round((deadline - world.time) / (1 MINUTES)))] мин.<br>"
	return lines.Join("")
