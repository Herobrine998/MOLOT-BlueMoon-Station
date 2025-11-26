/obj/item/sensor_device1984
	name = "handheld crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	item_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/item/sensor_device1984/Initialize(mapload)
	.=..()
	crew_monitor = new(src)

/obj/item/sensor_device1984/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/item/sensor_device1984/attack_self(mob/user)
	ui_interact(user)

/obj/item/sensor_device1984/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	. = ..()
	if(!.)
		return FALSE

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !ishuman(user))
		return FALSE

	if(over_object == user)
		attack_self(user)
		return TRUE

	return FALSE

/obj/item/sensor_device1984/ui_interact(mob/user, datum/tgui/ui = null)
	crew_monitor.ui_interact(user, ui)

/obj/item/sensor_device1984/advanced

/obj/item/sensor_device1984/advanced/command
	name = "command crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на членов командования."
	item_state = "blueshield_monitor"
	icon_state = "c_scanner"

/obj/item/sensor_device1984/advanced/command/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_COMMAND

/obj/item/sensor_device1984/advanced/security
	name = "security crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на членов службы безопасности."
	item_state = "brig_monitor"
	icon_state = "s_scanner"

/obj/item/sensor_device1984/advanced/security/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_SECURITY

/obj/item/sensor_device1984/advanced/mining
	name = "mining crew monitor"
	desc = "Миниатюрное устройство, с помощью которого можно отслеживать датчики членов экипажа станции. Эта модель настроена на шахтёрский персонал станции."
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	icon_state = "shaft_scanner"
	item_state = "mining_scanner"

/obj/item/sensor_device1984/advanced/mining/Initialize(mapload)
	. = ..()
	crew_monitor.tab_index = CREW_VISION_MINING
