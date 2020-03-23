/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_FLAGS_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	light_color = "#4c4cff"
	light_power = 3
	w_class = ITEM_SIZE_SMALL
	var/last_process = 0
	var/datum/cult/reveal/power
	var/static/list/scum

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='userdanger'>[user] is impaling himself with the [name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/atom_init()
	. = ..()
	if(!scum)
		scum = typecacheof(list(/mob/living/simple_animal/construct, /obj/structure/cult, /obj/effect/rune, /mob/dead/observer))
	power = new(src)

/obj/item/weapon/nullrod/equipped(mob/user, slot)
	if(user.mind && user.mind.assigned_role == "Chaplain")
		START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(power)
	return ..()

/obj/item/weapon/nullrod/dropped(mob/user)
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/process()
	if(last_process + 60 >= world.time)
		return
	last_process = world.time
	var/turf/turf = get_turf(loc)
	for(var/A in range(6, turf))
		if(iscultist(A) || is_type_in_typecache(A, scum))
			set_light(3)
			addtimer(CALLBACK(src, .atom/proc/set_light, 0), 20)
			return
	if(istype(src, /obj/item/weapon/nullrod/staff)) //repair blind when re-entering in game
		var/obj/item/weapon/nullrod/staff/S = src
		if(S.brainmob && S.brainmob.ckey && S.brainmob.stat != CONSCIOUS)
			S.brainmob.stat = CONSCIOUS
			S.brainmob.blinded = FALSE

/obj/item/weapon/nullrod/attack(mob/M, mob/living/user) //Paste from old-code to decult with a null rod.
	if (!(ishuman(user) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='danger'> You don't have the dexterity to do this!</span>")
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey])", user)

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>The rod slips out of your hand and hits your head.</span>")
		user.adjustBruteLoss(10)
		user.Paralyse(20)
		return

	if (M.stat != DEAD)
		if((M.mind in ticker.mode.cult) && user.mind && user.mind.assigned_role == "Chaplain" && prob(33))
			to_chat(M, "<span class='danger'>The power of [src] clears your mind of the cult's influence!</span>")
			to_chat(user, "<span class='danger'>You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal.</span>")
			ticker.mode.remove_cultist(M.mind)
		else
			to_chat(user, "<span class='danger'>The rod appears to do nothing.</span>")
		M.visible_message("<span class='danger'>[user] waves [src] over [M.name]'s head</span>")

/obj/item/weapon/nullrod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (proximity_flag && istype(target, /turf/simulated/floor) && user.mind && user.mind.assigned_role == "Chaplain")
		to_chat(user, "<span class='notice'>You hit the floor with the [src].</span>")
		power.action(user, 1)

/obj/item/weapon/nullrod/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	if(user.mind.assigned_role == "Chaplain" && istype(W, /obj/item/weapon/storage/bible) && !istype(src, /obj/item/weapon/nullrod/staff))
		var/obj/item/weapon/storage/bible/B = W
		var/obj/item/weapon/nullrod/staff/staff = new /obj/item/weapon/nullrod/staff(loc)
		if(istype(B.loc, /mob/living))
			var/mob/living/M = B.loc
			M.drop_from_inventory(staff)
		staff.god_name = B.deity_name
		staff.god_lore = B.god_lore
		qdel(src)
		if(B.icon_state == "koran")
			staff.islam = TRUE

/obj/item/weapon/nullrod/staff
	name = "Divine staff"
	desc = "A mystical and frightening staff with ancient magic. Only one chaplain remembers how to use it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "talking_staff"
	item_state = "talking_staff"
	w_class = ITEM_SIZE_NORMAL
	req_access = list(access_chapel_office)

	var/god_name = "Space-Jesus"
	var/god_lore = ""
	var/mob/living/simple_animal/shade/god/brainmob = null
	var/soul_inside = FALSE //you need to then remove the afk-god
	var/searching = FALSE
	var/next_ping = 0
	var/islam = FALSE

/obj/item/weapon/nullrod/staff/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	if(istype(W, /obj/item/device/soulstone)) //mb, the only way to pull out god
		var/obj/item/device/soulstone/S = W
		if(S.imprinted == "empty")
			S.imprinted = brainmob.name
			S.transfer_soul("SHADE", src.brainmob, user)
	if(istype(W, /obj/item/weapon/storage/bible))
		reset_search() //force kick god from staff

/obj/item/weapon/nullrod/staff/attack_self(mob/living/carbon/human/user)
	if(user.mind.assigned_role == "Chaplain")
		if(!soul_inside && !brainmob && !searching)
			//Start the process of searching for a new user.
			to_chat(user, "<span class='notice'>You attempt to wake the spirit of the staff...</span>")
			icon_state = "talking_staffanim"
			light_power = 5
			searching = TRUE
			request_player()
			addtimer(CALLBACK(src, .proc/reset_search), 600)

/obj/item/weapon/nullrod/staff/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_PAI) && role_available_in_minutes(O, ROLE_PAI))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find("chstaff") && (ROLE_PAI in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C)

/obj/item/weapon/nullrod/staff/proc/question(client/C)
	if(!C)	
		return
	var/response = alert(C, "Someone is requesting a your soul in divine staff?", "Staff request", "No", "Yeeesss", "Never for this round")
	if(!C || (soul_inside && brainmob && brainmob.ckey) || !searching)	
		return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yeeesss")
		transfer_personality(C.mob)
	else if (response == "Never for this round")
		C.prefs.ignore_question += "chstaff"

/obj/item/weapon/nullrod/staff/proc/transfer_personality(mob/candidate)
	searching = FALSE

	if(brainmob)
		to_chat(brainmob, "<span class='userdanger'>You are no longer our god!</span>")
		qdel(brainmob) //create new god, otherwise the old mob could not be woken up

	brainmob = new(src)
	brainmob.mutations.Add(XRAY) //its the god
	brainmob.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
	brainmob.status_flags |= GODMODE

	brainmob.mind = candidate.mind
	brainmob.ckey = candidate.ckey
	brainmob.name = "[god_name] [pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")]"
	brainmob.real_name = name
	brainmob.mind.assigned_role = "Chaplain`s staff"
	brainmob.mind.memory = god_lore
	candidate.cancel_camera()
	candidate.reset_view()
	if(islam)
		brainmob.islam = TRUE
		brainmob.speak.Add("[god_name] akbar!")

	name = "Staff of [god_name]"
	if(god_name == "Aghanim") //sprite is very similar
		name = "Aghanim's Scepter"

	desc = "Stone sometimes glow. Pray for mercy on [god_name]."
	to_chat(brainmob, "<b>You are a god, brought into existence on [station_name()].</b>")
	to_chat(brainmob, "<b>The priest has called you, you can command them, because you are their god.</b>")
	to_chat(brainmob, "<b>All that is required of you is a creative image of the imprisoned god in the staff.</b>")
	if(god_lore == "")
		to_chat(brainmob, "<b>You can be both evil Satan thirsting and ordering sacrifices, and a good Jesus who wants more slaves.</b>")
	else
		to_chat(brainmob, "<b>Check your lore in notes.</b>")
	to_chat(brainmob, "<span class='userdanger'><font size =3><b>You do not know everything that happens and happened in the round!</b></font></span>")
 
	icon_state = "talking_staffsoul"
	soul_inside = TRUE

/obj/item/weapon/nullrod/staff/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.
	if(soul_inside && brainmob && brainmob.ckey) 
		return

	if(brainmob && !brainmob.ckey)
		qdel(brainmob)

	searching = FALSE
	soul_inside = FALSE
	icon_state = "talking_staff"
	visible_message("<span class='notice'>The stone of \the [src] stopped glowing, why didn't you please the god?</span>")

/obj/item/weapon/nullrod/staff/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n[desc]</span>\n"
	if(soul_inside && brainmob && brainmob.ckey)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					msg += "<span class='warning'>Divine presence is weakened.</span>\n" //afk
			if(UNCONSCIOUS)
				msg += "<span class='warning'>Divine presence is not tangible.</span>\n"
			if(DEAD)
				msg += "<span class='deadsay'>Divine presence faded.</span>\n"
	else
		msg += ""
	msg += "<span class='info'>*---------*</span>"
	to_chat(user, msg)

/obj/item/weapon/nullrod/staff/attack_ghost(mob/dead/observer/O)
	if(next_ping > world.time)
		return
	
	next_ping = world.time + 5 SECONDS
	audible_message("<span class='notice'>\The [src] stone blinked.</span>", deaf_message = "\The [src] stone blinked.")

/obj/item/weapon/nullrod/staff/Destroy()
	to_chat(brainmob, "<span class='userdanger'>You were destroyed!</span>")
	qdel(brainmob)
	return ..()
