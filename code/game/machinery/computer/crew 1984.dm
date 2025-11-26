GLOBAL_DATUM_INIT(crew_repository, /datum/repository/crew, new())

/datum/repository/crew
	var/static/list/bold_jobs
	var/static/list/security_jobs_list
	var/static/list/mining_jobs_list

/datum/repository/crew/New()
	cache_data = list()
	..()

/datum/repository/crew/proc/health_data(turf/T)
	var/list/crewmembers = list()
	if(!T)
		return crewmembers

	var/z_level = "[T.z]"
	var/datum/cache_entry/cache_entry = cache_data[z_level]
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data[z_level] = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	// Initialize the jobs here because in New(), GLOB.command_positions may not be inited yet
	if(!bold_jobs)
		bold_jobs = list()
		bold_jobs += GLOB.command_positions
		bold_jobs += get_all_centcom_jobs()
		bold_jobs += list(JOB_TITLE_REPRESENTATIVE, JOB_TITLE_BLUESHIELD, JOB_TITLE_JUDGE)

	// It's needed for correct finding security crew in CrewMonitor.js
	if(!security_jobs_list)
		security_jobs_list = list()
		security_jobs_list += GLOB.security_positions

	if(!mining_jobs_list)
		mining_jobs_list = list()
		mining_jobs_list += GLOB.mining_positions

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || C.sensor_mode == SUIT_SENSOR_OFF || !C.has_sensor)
			continue
		var/turf/pos = get_turf(C)
		if(!istype(pos) || !T)
			continue
		if((pos.z != T.z) && !(is_station_level(pos.z) && is_station_level(T.z)) && !(HAS_TRAIT(H, TRAIT_MULTIZ_SUIT_SENSORS))) // same z_level or both on STATION_LEVEL or has special trait
			continue
		var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1, "ref" = "\ref[H]")

		crewmemberData["sensor_type"] = C.sensor_mode
		crewmemberData["name"] = H.get_authentification_name(if_no_id=UNKNOWN_STATUS_RUS)
		crewmemberData["rank"] = H.get_authentification_rank(if_no_id=UNKNOWN_STATUS_RUS, if_no_job=NOJOB_STATUS_RUS)
		crewmemberData["assignment"] = H.get_assignment(if_no_id=UNKNOWN_STATUS_RUS, if_no_job=NOJOB_STATUS_RUS)
		crewmemberData["is_command"] = (crewmemberData["rank"] in bold_jobs)
		crewmemberData["is_security"] = (crewmemberData["rank"] in security_jobs_list)
		crewmemberData["is_shaft_miner"] = (crewmemberData["rank"] in mining_jobs_list)

		if(C.sensor_mode >= SUIT_SENSOR_BINARY)
			crewmemberData["dead"] = H.stat == DEAD

		if(C.sensor_mode >= SUIT_SENSOR_VITAL)
			crewmemberData["stat"] = H.stat
			crewmemberData["health"] = H.health
			crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
			crewmemberData["tox"] = round(H.getToxLoss(), 1)
			crewmemberData["fire"] = round(H.getFireLoss(), 1)
			crewmemberData["brute"] = round(H.getBruteLoss(), 1)

		if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
			var/area/A = get_area(H)
			crewmemberData["area"] = A.name
			crewmemberData["x"] = pos.x
			crewmemberData["y"] = pos.y
			crewmemberData["z"] = pos.z

		crewmembers[++crewmembers.len] = crewmemberData

	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = crewmembers

	return crewmembers

// Used in sensor devices. I hope this will make smthng good.
#define CREW_VISION_COMMAND 0
#define CREW_VISION_SECURITY 1
#define CREW_VISION_MINING 2
#define CREW_VISION_COMMON 3

#define MIN_ZOOM 1
#define MAX_ZOOM 8
#define MIN_TAB_INDEX 0
#define MAX_TAB_INDEX 1

/datum/ui_module
	var/name
	var/datum/host

/datum/ui_module/New(datum/_host)
	host = _host

/datum/ui_module/Destroy()
	host = null
	return ..()

/datum/ui_module/ui_host()
	return host ? host : src

/datum/ui_module/ui_close(mob/user)
	if(host)
		host.ui_close(user)

/datum/ui_module/crew_monitor
	name = "Монитор наблюдения за экипажем"
	/// The ID of the currently opened UI tab
	var/tab_index = CREW_VISION_COMMON
	/// The zoom level of the UI map view
	var/zoom = 1
	/// The X offset of the UI map
	var/offset_x = 0
	/// The Y offset of the UI map
	var/offset_y = 0
	/// A list of displayed names. Displayed names were intentionally chosen over ckeys,
	/// refs, or uids, because exposing any of the aforementioned to the client could allow
	/// an exploit to detect changelings on sensors.
	var/highlighted_names = list()

/datum/ui_module/crew_monitor/ui_act(action, params)
	if(..())
		return TRUE

	var/turf/T = get_turf(ui_host())
	if(!T || !is_level_reachable(T.z))
		to_chat(usr, span_danger("Удалённый сервер не отвечает на запросы") + ": база данных вне зоны досягаемости.")
		return FALSE

	switch(action)
		if("track")
			var/mob/living/carbon/human/human = locate(params["track"]) in GLOB.human_list
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				if(hassensorlevel(human, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(human)
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(human)
			return TRUE
		if("set_tab_index")
			var/new_tab_index = text2num(params["tab_index"])
			if(isnull(new_tab_index) || new_tab_index < MIN_TAB_INDEX || new_tab_index > MAX_TAB_INDEX)
				return
			tab_index = new_tab_index
		if("set_zoom")
			var/new_zoom = text2num(params["zoom"])
			if(isnull(new_zoom) || new_zoom < MIN_ZOOM || new_zoom > MAX_ZOOM)
				return
			zoom = new_zoom
		if("set_offset")
			var/new_offset_x = text2num(params["offset_x"])
			var/new_offset_y = text2num(params["offset_y"])
			if(isnull(new_offset_x) || isnull(new_offset_y))
				return
			offset_x = new_offset_x
			offset_y = new_offset_y
		if("add_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names += list(name)
		if("remove_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names -= list(name)
		if("clear_highlighted_names")
			highlighted_names = list()

/datum/ui_module/crew_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)

	if(GLOB.communications_blackout)
		to_chat(user, span_warning("Монитор показывает странные символы. Разобрать в них что-то невозможно."))
		if(ui)
			ui.close()
		return

	if(!ui)
		ui = new(user, src, "CrewMonitor", name)
		ui.open()

/datum/ui_module/crew_monitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/datum/ui_module/crew_monitor/ui_static_data(mob/user)
	var/list/static_data = list()
	var/list/station_level_numbers = list()
	var/list/station_level_names = list()
	for(var/z_level in levels_by_trait(STATION_LEVEL))
		station_level_numbers += z_level
		station_level_names += check_level_trait(z_level, STATION_LEVEL)
	static_data["stationLevelNum"] = station_level_numbers
	static_data["stationLevelName"] = station_level_names
	return static_data

/datum/ui_module/crew_monitor/ui_data(mob/user)
	var/list/data = list()
	var/turf/T = get_turf(ui_host())

	data["tabIndex"] = tab_index
	data["zoom"] = zoom
	data["offsetX"] = offset_x
	data["offsetY"] = offset_y

	data["isAI"] = isAI(user)
	data["isObserver"] = isobserver(user)
	data["crewmembers"] = GLOB.crew_repository.health_data(T)
	data["critThreshold"] = HEALTH_THRESHOLD_CRIT
	data["highlightedNames"] = highlighted_names
	switch(tab_index)
		if(CREW_VISION_COMMAND)
			data["isBS"] = 1
		if(CREW_VISION_SECURITY)
			data["isBP"] = 1
		if(CREW_VISION_MINING)
			data["isMM"] = TRUE
	return data

/datum/ui_module/crew_monitor/ghost/ui_state(mob/user)
	return GLOB.observer_state

#undef MIN_ZOOM
#undef MAX_ZOOM
#undef MIN_TAB_INDEX
#undef MAX_TAB_INDEX
