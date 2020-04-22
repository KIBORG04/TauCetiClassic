/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/religion.dmi'
	icon_state = "altar"
	density = TRUE
	anchored = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	climbable = TRUE
	pass_flags = PASSTABLE
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	var/datum/religion_sect/sect_to_altar // easy access!
	var/datum/religion_rites/performing_rite

/obj/structure/altar_of_gods/examine(mob/user)
	. = ..()
	var/can_i_see = FALSE
	var/msg = ""
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind && L.mind.holy_role)
			can_i_see = TRUE

	if(!can_i_see || !sect_to_altar)
		return

	msg += "<span class='notice'>The sect currently has [round(sect_to_altar.favor)] favor with [ticker.Bible_deity_name].\n</span>"
	if(!sect_to_altar.rites_list)
		return
	msg += "List of available Rites:\n"
	for(var/i in sect_to_altar.rites_list)
		msg += i
	if(msg)
		to_chat(user, msg)


/obj/structure/altar_of_gods/atom_init()
	. = ..()
	if(religious_sect)
		sect_to_altar = religious_sect
		if(sect_to_altar.altar_icon)
			icon = sect_to_altar.altar_icon
		if(sect_to_altar.altar_icon_state)
			icon_state = sect_to_altar.altar_icon_state

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, "<span class='warning'>[pushed_mob] is buckled to [pushed_mob.buckled]!</span>")
		return ..()
	to_chat(user,"<span class='notice>You try to coax [pushed_mob] onto [src]...</span>")
	if(!do_after(user, (5 SECONDS), target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	//If we can sac, we do nothing but the sacrifice instead of typical attackby behavior (IE damage the structure)
	if(sect_to_altar && sect_to_altar.can_sacrifice(C, user))
		sect_to_altar.on_sacrifice(C, user)
		return TRUE
	//everything below is assumed you're bibling it up
	if(istype(C, /obj/item/weapon/nullrod/staff))
		if(!religious_sect)
			to_chat(user, "<span class='notice'>First create a sect.</span>")
			return
		if(!religious_sect.god)
			var/obj/item/weapon/nullrod/staff/S = C
			religious_sect.god = S.brainmob
			to_chat(user, "<span class='notice'>You binding your god to sect!")
			religious_sect.give_god_spells()
			return
	if(!istype(C, /obj/item/weapon/storage/bible))
		return
	if(sect_to_altar)
		if(!sect_to_altar.rites_list)
			to_chat(user, "<span class='notice'>Your sect doesn't have any rites to perform!")
			return
		var/rite_select = input(user,"Select a rite to perform!", "Select a rite", null) in sect_to_altar.rites_list
		if(!rite_select)
			to_chat(user,"<span class ='warning'>You cannot perform the rite at this time.</span>")
			return
		var/selection2type = sect_to_altar.rites_list[rite_select]
		performing_rite = new selection2type(src)
		if(!performing_rite.perform_rite(user, src))
			QDEL_NULL(performing_rite)
		else
			performing_rite.invoke_effect(user, src)
			sect_to_altar.adjust_favor(-performing_rite.favor_cost)
			QDEL_NULL(performing_rite)
		return

	if(user.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='warning'>You are not the high priest, and therefore cannot select a religious sect.")
		return

	var/list/available_options = generate_available_sects(user)
	if(!available_options)
		return

	var/sect_select = input(user,"Select a sect (You CANNOT revert this decision!)","Select a Sect",null) in available_options
	if(!sect_select)
		to_chat(user,"<span class ='warning'>You cannot select a sect at this time.</span>")
		return
	
	var/type_selected = available_options[sect_select]
	religious_sect = new type_selected()

	if(istype(religious_sect, /datum/religion_sect/custom))
		religious_sect.name = ticker.Bible_religion_name

	for(var/i in player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(am_i_holy_living.mind && !am_i_holy_living.mind.holy_role)
			continue
		religious_sect.on_conversion(am_i_holy_living)

	sect_to_altar = religious_sect
	if(sect_to_altar.altar_icon)
		icon = sect_to_altar.altar_icon
	if(sect_to_altar.altar_icon_state)
		icon_state = sect_to_altar.altar_icon_state

/obj/structure/altar_of_gods/proc/generate_available_sects(mob/user) //eventually want to add sects you get from unlocking certain achievements
	. = list()
	for(var/i in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/not_a_real_instance_rs = i
		if(initial(not_a_real_instance_rs.starter))
			. += list(initial(not_a_real_instance_rs.name) = i)
