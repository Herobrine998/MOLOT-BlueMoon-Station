/obj/machinery/computer/supplyquest
	name = "Supply Request Console"
	desc = "Консоль приёма запросов на поставку грузов Центральному командованию и частным заказчикам."
	icon_screen = "bounty"
	light_color = "#E2853D"
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/computer/bounty
	var/printer_ready = 0

// Старый путь сохраняет размещение консолей на картах и совместимость плат.
/obj/machinery/computer/bounty
	name = "\improper Nanotrasen bounty console"
	parent_type = /obj/machinery/computer/supplyquest

/obj/machinery/computer/supplyquest/Initialize(mapload)
	. = ..()
	SScargo_quests.consoles += src

/obj/machinery/computer/supplyquest/Destroy()
	SScargo_quests.consoles -= src
	return ..()

/obj/machinery/computer/supplyquest/ui_interact(mob/user, datum/tgui/ui)
	SScargo_quests.ensure_quests()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoBountyConsole", name)
		ui.open()

/obj/machinery/computer/supplyquest/ui_data(mob/user)
	var/list/data = list()
	var/list/orders = list()
	for(var/datum/cargo_quests_storage/quest as anything in SScargo_quests.quest_storages)
		orders += list(list(
			"ref" = REF(quest),
			"customer" = quest.customer.group_name,
			"target_departament" = quest.customer.departament_name,
			"department" = quest.department,
			"tier" = quest.tier,
			"reward" = quest.reward(),
			"active" = quest.active,
			"can_reroll" = quest.can_reroll,
			"can_extend" = quest.time_add_count < CARGO_QUEST_MAX_EXTENSIONS,
			"extensions" = quest.time_add_count,
			"fast_bonus" = world.time < quest.fast_deadline,
			"timer" = max(0, round((quest.deadline - world.time) / 10)),
			"quests_items" = quest.interface_items,
			"priority" = quest.priority_multiplier > 1,
		))
	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	data["cargo_money"] = cargo_account?.account_balance || 0
	data["quests"] = orders
	data["moving"] = SSshuttle.supply?.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply?.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply?.getTimerStr()
	data["completed"] = SScargo_quests.completed_count
	data["total_reward"] = SScargo_quests.total_reward
	data["can_manage"] = allowed(user) || IsAdminGhost(user)
	var/list/sales = list()
	var/static/list/category_names = list(
		"Emergency" = "Аварийное снаряжение",
		"Security" = "Безопасность",
		"Engineering" = "Инженерия",
		"Medical" = "Медицина",
		"Science" = "Наука",
		"Food & Hydroponics" = "Питание и гидропоника",
		"Vending" = "Торговые автоматы",
	)
	for(var/category in SScargo_quests.sales)
		sales += list(list("name" = category_names[category] || category, "discount" = round(SScargo_quests.sales[category] * 100)))
	data["sales"] = sales
	return data

/obj/machinery/computer/supplyquest/ui_act(action, list/params)
	if(..())
		return
	if(!allowed(usr) && !IsAdminGhost(usr))
		to_chat(usr, span_warning("Доступ разрешён только сотрудникам отдела снабжения."))
		return FALSE
	var/datum/cargo_quests_storage/quest = locate(params["uid"]) in SScargo_quests.quest_storages
	if(!quest || world.time >= quest.deadline)
		return FALSE
	add_fingerprint(usr)
	switch(action)
		if("activate")
			if(!quest.activate(usr))
				return FALSE
			print_text(quest.printout(), "supply request")
			return TRUE
		if("denied")
			if(quest.active || !quest.can_reroll)
				return FALSE
			SScargo_quests.replace_quest(quest, reroll = TRUE)
			return TRUE
		if("print_order")
			if(world.time < printer_ready)
				return FALSE
			printer_ready = world.time + 10 SECONDS
			print_text(quest.printout(), "supply request")
			return TRUE
		if("add_time")
			return quest.add_time()

/obj/machinery/computer/supplyquest/proc/print_text(text, paper_name)
	var/obj/item/paper/paper = new(get_turf(src))
	paper.name = paper_name
	paper.add_raw_text(text)
	playsound(src, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
