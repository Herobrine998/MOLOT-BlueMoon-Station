SUBSYSTEM_DEF(cargo_quests)
	name = "Cargo Quests"
	flags = SS_NO_FIRE
	var/list/quest_storages = list()
	var/list/customers = list()
	var/list/customer_groups = list()
	var/list/catalog = list()
	var/list/catalog_datums = list()
	var/datum/cargo_quest_catalog/plasma_catalog
	var/list/consoles = list()
	var/list/icons = list()
	var/list/sales = list()
	var/quests_started = FALSE
	var/completed_count = 0
	var/total_reward = 0

/datum/controller/subsystem/cargo_quests/Initialize(timeofday)
	for(var/path in subtypesof(/datum/quest_customer))
		var/datum/quest_customer/customer = new path
		if(!customer.departament_name)
			qdel(customer)
			continue
		customers[customer.departament_name] = customer
		LAZYADD(customer_groups[customer.group_name], customer)
	for(var/path in subtypesof(/datum/cargo_quest_catalog))
		var/datum/cargo_quest_catalog/category = new path
		if(!length(category.targets) || !category.department)
			qdel(category)
			continue
		catalog_datums += category
		if(path == /datum/cargo_quest_catalog/minerals)
			plasma_catalog = category
		var/key = "[category.tier]"
		if(!catalog[key])
			catalog[key] = list()
		var/list/departments = catalog[key]
		if(!departments[category.department])
			departments[category.department] = list()
		var/list/entries = departments[category.department]
		for(var/target in category.targets)
			entries[target] = category
	return ..()

/datum/controller/subsystem/cargo_quests/Destroy()
	QDEL_LIST(quest_storages)
	consoles.Cut()
	catalog.Cut()
	customer_groups.Cut()
	plasma_catalog = null
	QDEL_LIST(catalog_datums)
	QDEL_LIST_ASSOC_VAL(customers)
	icons.Cut()
	sales.Cut()
	return ..()

/datum/controller/subsystem/cargo_quests/proc/ensure_quests()
	if(quests_started)
		return
	quests_started = TRUE
	for(var/tier in 1 to 4)
		for(var/i in 1 to (5 - tier))
			var/group = tier == 1 && i == 4 ? CARGO_QUEST_PLASMA : pick(CARGO_QUEST_CENTCOM, CARGO_QUEST_CENTCOM, CARGO_QUEST_CORPORATION)
			create_quest(tier, group)

/datum/controller/subsystem/cargo_quests/proc/create_quest(tier, group, can_reroll = TRUE)
	var/datum/cargo_quests_storage/quest = new
	quest.generate(pick(customer_groups[group]), tier)
	quest.can_reroll = can_reroll
	quest_storages += quest
	return quest

/datum/controller/subsystem/cargo_quests/proc/replace_quest(datum/cargo_quests_storage/quest, reroll = FALSE, completed, list/result)
	if(QDELETED(quest) || !(quest in quest_storages))
		return
	quest_storages -= quest
	if(!reroll && quest.active)
		for(var/obj/machinery/computer/supplyquest/console as anything in consoles)
			if(console.is_operational())
				console.print_text(quest.printout(result, completed), "supply report")
	create_quest(quest.tier, quest.customer.group_name, !reroll)
	qdel(quest)

/datum/controller/subsystem/cargo_quests/proc/get_icon(atom/path)
	if(!icons[path])
		icons[path] = icon2base64(icon(initial(path.icon), initial(path.icon_state)))
	return icons[path]

/datum/controller/subsystem/cargo_quests/proc/check_delivery(obj/structure/big_delivery/delivery)
	if(!istype(delivery) || delivery.anchored)
		return FALSE
	var/obj/structure/closet/crate/crate = locate() in delivery.contents
	if(!crate || !length(crate.contents))
		return FALSE
	ensure_quests()
	var/datum/cargo_quests_storage/best_quest
	var/list/best_result
	for(var/datum/cargo_quests_storage/quest as anything in quest_storages)
		if(!quest.active || world.time >= quest.deadline)
			continue
		var/list/result = quest.evaluate(delivery, crate)
		if(!result || result["reward"] <= 0)
			continue
		if(!best_result || result["reward"] > best_result["reward"])
			best_quest = quest
			best_result = result
	if(!best_quest)
		return FALSE
	var/value = best_result["reward"]
	best_quest.customer.send_reward(value, best_quest.department)
	if(best_result["complete"] && !best_result["wrong_recipient"] && !best_result["extra"])
		best_quest.customer.set_sale(best_result["quick"] ? 2 : 1)
	completed_count++
	total_reward += value
	delivery.investigate_log("Запрос [best_quest.customer.departament_name], [best_quest.department], тир [best_quest.tier]: выплачено [value] кредитов.", INVESTIGATE_CARGO)
	replace_quest(best_quest, completed = TRUE, result = best_result)
	// Содержимое принято целиком; оно не должно повторно продаваться обычным экспортом.
	for(var/atom/movable/content as anything in reverseRange(crate.GetAllContents()))
		qdel(content)
	qdel(delivery)
	return TRUE
