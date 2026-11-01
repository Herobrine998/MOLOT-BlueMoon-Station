/datum/round_event_control/high_priority_bounty
	name = "High Priority Bounty"
	typepath = /datum/round_event/high_priority_bounty
	max_occurrences = 1
	weight = 50
	earliest_start = 10
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Повышает награду одного запроса на поставку втрое."

/datum/round_event/high_priority_bounty/announce(fake)
	priority_announce("Центральное командование утроило награду за один из запросов на поставку. Подробности доступны на консолях запросов отдела снабжения.", "Программа поставок Nanotrasen")

/datum/round_event/high_priority_bounty/start()
	SScargo_quests.ensure_quests()
	var/list/available = list()
	for(var/datum/cargo_quests_storage/quest as anything in SScargo_quests.quest_storages)
		if(quest.priority_multiplier == 1)
			available += quest
	if(length(available))
		var/datum/cargo_quests_storage/quest = pick(available)
		quest.priority_multiplier = 3

