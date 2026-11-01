/datum/quest_customer
	var/departament_name
	var/group_name
	var/list/cargo_sale = list()
	var/reward_multiplier = 1

/datum/quest_customer/proc/set_sale(multiplier)
	// Скидки одного раздела не складываются и не перемножаются при повторных поставках.
	for(var/category in cargo_sale)
		SScargo_quests.sales[category] = max(SScargo_quests.sales[category], cargo_sale[category] * multiplier)

/datum/quest_customer/proc/send_reward(value, department)
	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(group_name != CARGO_QUEST_CORPORATION)
		cargo_account.adjust_money(value)
		cargo_account.add_transaction("Выполнение запроса: [departament_name]", value, departament_name, "Консоль запросов")
		return
	var/station_share = round(value * 0.25)
	var/department_share = round(value * 0.15)
	var/cargo_share = value - station_share - department_share
	var/static/list/accounts = list(
		CARGO_QUEST_MEDICAL = ACCOUNT_MED,
		CARGO_QUEST_SCIENCE = ACCOUNT_SCI,
		CARGO_QUEST_SERVICE = ACCOUNT_SRV,
		CARGO_QUEST_MINING = ACCOUNT_CAR,
	)
	var/datum/bank_account/department_account = SSeconomy.get_dep_account(accounts[department])
	if(GLOB.station_account)
		GLOB.station_account.adjust_money(station_share)
		GLOB.station_account.add_transaction("Корпоративный запрос: [departament_name]", station_share, departament_name, "Консоль запросов")
	else
		cargo_share += station_share
	if(department_account)
		department_account.adjust_money(department_share)
		department_account.add_transaction("Доля отдела за запрос: [departament_name]", department_share, departament_name, "Консоль запросов")
	else
		cargo_share += department_share
	cargo_account.adjust_money(cargo_share)
	cargo_account.add_transaction("Корпоративный запрос: [departament_name]", cargo_share, departament_name, "Консоль запросов")

/datum/quest_customer/centcomm
	group_name = CARGO_QUEST_CENTCOM

/datum/quest_customer/corp
	group_name = CARGO_QUEST_CORPORATION
	reward_multiplier = 3

/datum/quest_customer/plasma
	group_name = CARGO_QUEST_PLASMA

/datum/quest_customer/centcomm/xenoarcheology
	departament_name = "Центр ксеноархеологии"
	cargo_sale = list("Science" = 0.05, "Engineering" = 0.05)

/datum/quest_customer/centcomm/xenobiology
	departament_name = "Центр ксенобиологии"
	cargo_sale = list("Science" = 0.05, "Food & Hydroponics" = 0.05)

/datum/quest_customer/centcomm/alloy_and_composite
	departament_name = "Центр сплавов и композитов"
	cargo_sale = list("Science" = 0.05, "Engineering" = 0.10)

/datum/quest_customer/centcomm/valuetech
	departament_name = "Центр информационных технологий"
	cargo_sale = list("Science" = 0.10)

/datum/quest_customer/centcomm/anomaly_research
	departament_name = "Центр исследования аномалий"
	cargo_sale = list("Science" = 0.10)

/datum/quest_customer/centcomm/cryogenic_physics
	departament_name = "Центр криогенной физики"
	cargo_sale = list("Science" = 0.05, "Engineering" = 0.05, "Medical" = 0.05)

/datum/quest_customer/centcomm/applied_physics
	departament_name = "Центр прикладной физики"
	cargo_sale = list("Science" = 0.05, "Engineering" = 0.05, "Security" = 0.05)

/datum/quest_customer/centcomm/biological_warfare
	departament_name = "Подразделение биологического вооружения"
	cargo_sale = list("Security" = 0.05, "Medical" = 0.05)

/datum/quest_customer/centcomm/gene_mutation
	departament_name = "Подразделение генной инженерии"
	cargo_sale = list("Medical" = 0.10)

/datum/quest_customer/centcomm/xenoanatomy
	departament_name = "Подразделение ксеноанатомии"
	cargo_sale = list("Medical" = 0.10)

/datum/quest_customer/centcomm/exp_pharmacology
	departament_name = "Центр экспериментальной фармакологии"
	cargo_sale = list("Science" = 0.05, "Medical" = 0.05)

/datum/quest_customer/centcomm/chimera
	departament_name = "Подразделение \"Химера-731\""
	cargo_sale = list("Medical" = 0.05, "Food & Hydroponics" = 0.05)

/datum/quest_customer/centcomm/organic_farm
	departament_name = "Органическая ферма НТ"
	cargo_sale = list("Engineering" = 0.05, "Food & Hydroponics" = 0.10)

/datum/quest_customer/centcomm/fleet_vessel
	departament_name = "Космодром флота НТ"
	cargo_sale = list("Security" = 0.10, "Engineering" = 0.05)

/datum/quest_customer/centcomm/advanced_expeditionary
	departament_name = "Передовой экспедиционный корпус НТ"
	cargo_sale = list("Security" = 0.05, "Engineering" = 0.05)

/datum/quest_customer/centcomm/space_mining
	departament_name = "Космическое шахтёрское предприятие НТ"
	cargo_sale = list("Science" = 0.05, "Engineering" = 0.05)

/datum/quest_customer/centcomm/pioneer_outpost
	departament_name = "Пионерский аванпост НТ"
	cargo_sale = list("Medical" = 0.05, "Engineering" = 0.05, "Security" = 0.05)

/datum/quest_customer/plasma/enrichment
	departament_name = "Комплекс по обогащению плазмы"
	cargo_sale = list("Emergency" = 0.03)

/datum/quest_customer/plasma/refinery
	departament_name = "Комплекс по переработке плазмы"
	cargo_sale = list("Emergency" = 0.03)

/datum/quest_customer/plasma/applications
	departament_name = "Отделение реализации плазмы"
	cargo_sale = list("Emergency" = 0.03)

/datum/quest_customer/plasma/study
	departament_name = "Центр изучения плазмы"
	cargo_sale = list("Emergency" = 0.03)

/datum/quest_customer/centcomm/wares_shipping
	departament_name = "Подразделение логистики"
	cargo_sale = list("Vending" = 0.05, "Food & Hydroponics" = 0.05)

/datum/quest_customer/centcomm/commercial
	departament_name = "Отдел торговли"
	cargo_sale = list("Vending" = 0.05, "Food & Hydroponics" = 0.05)

/datum/quest_customer/centcomm/business_stategy
	departament_name = "Отдел делового планирования"
	cargo_sale = list("Emergency" = 0.05, "Vending" = 0.05)

/datum/quest_customer/centcomm/headquarters
	departament_name = "Главный штаб"
	cargo_sale = list("Emergency" = 0.05, "Vending" = 0.05)

/datum/quest_customer/corp/chang
	departament_name = "Mr. Chang"

/datum/quest_customer/corp/donk
	departament_name = "Donk Co."

/datum/quest_customer/corp/waffle
	departament_name = "Waffle Co."

/datum/quest_customer/corp/biotech
	departament_name = "BioTech Solutions"

/datum/quest_customer/corp/einstein
	departament_name = "Einstein Engines Inc."

/datum/quest_customer/corp/cybersun
	departament_name = "Cybersun Industries"

/datum/quest_customer/corp/shellguard
	departament_name = "Shellguard Ammunitions"

/datum/quest_customer/corp/ward
	departament_name = "Ward-Takanashi"

/datum/quest_customer/corp/xion
	departament_name = "Xion Manufacturing Group"

/datum/quest_customer/corp/bishop
	departament_name = "Bishop Cybernetics"

/datum/quest_customer/corp/robust
	departament_name = "Robust Industries LLC"

/datum/quest_customer/corp/gilthari
	departament_name = "Gilthari Exports"

/datum/quest_customer/corp/major
	departament_name = "Major Bill's T&S"

/datum/quest_customer/corp/haakon
	departament_name = "Haakon Group"
