var/global/list/obj/item/candle/ghost/ghost_candles = list()
#define CANDLE_LUMINOSITY	3

/obj/item/candle
	name = "white candle"
	desc = "In Greek myth, Prometheus stole fire from the Gods and gave it to \
		humankind. The jewelry he kept for himself."

	icon = 'icons/obj/candle.dmi'
	icon_state = "white_candle"
	item_state = "white_candle"

	var/candle_color
	w_class = ITEM_SIZE_TINY

	var/wax = 0
	var/lit = FALSE
	light_color = LIGHT_COLOR_FIRE

	var/infinite = FALSE
	var/start_lit = FALSE

	var/faded_candle = /obj/item/trash/candle

/obj/item/candle/atom_init()
	. = ..()
	wax = rand(600, 800)
	if(start_lit)
		// No visible message
		light(flavor_text = FALSE)
	update_icon()

/obj/item/candle/proc/light(flavor_text = "<span class='warning'>[usr] lights the [name].</span>")
	if(!lit)
		lit = TRUE
		//src.damtype = "fire"
		visible_message(flavor_text)
		set_light(CANDLE_LUMINOSITY, 1)
		START_PROCESSING(SSobj, src)
		playsound(src, 'sound/items/matchstick_light.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/item/candle/proc/calculate_lighting_stage(wax)
	var/lightning_stage
	if(wax > 450)
		lightning_stage = 1
	else if(wax > 200)
		lightning_stage = 2
	else
		lightning_stage = 3
	return lightning_stage

/obj/item/candle/update_icon()
	if(!istype(src, /obj/item/candle/chandelier))
		var/lightning_stage = calculate_lighting_stage(wax)
		icon_state = "[initial(icon_state)][lightning_stage][lit ? "_lit" : ""]"
		if(lit)
			item_state = "[initial(icon_state)]_lit"
		else
			item_state = "[initial(icon_state)]"
	else
		var/obj/item/candle/chandelier/chandelier = src
		for(var/i in chandelier.place)
			if(chandelier.candles[i])
				var/obj/item/candle/C = chandelier.candles[i]
				var/lightning_stage = calculate_lighting_stage(C.wax)
				if(C.lit)
					cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage]"))
					add_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage]_lit"))
				if(C.wax >= 450)
					cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage - 1][C.lit ? "_lit" : ""]"))
					add_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage][C.lit ? "_lit" : ""]"))
				else if(C.wax >= 200)
					cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage - 1][C.lit ? "_lit" : ""]"))
					add_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage][C.lit ? "_lit" : ""]"))
				else if(C.wax >= 100)
					cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage - 1][C.lit ? "_lit" : ""]"))
					add_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage][C.lit ? "_lit" : ""]"))
				else if(C.wax == 0)
					cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage - 1][C.lit ? "_lit" : ""]"))
					add_overlay(image('icons/obj/candle.dmi', "[i]_[4]"))
	if(istype(loc, /mob))
		var/mob/M = loc
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.l_hand == src)
				M.update_inv_l_hand()
			if(H.r_hand == src)
				M.update_inv_r_hand()

/obj/item/candle/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn()) // Badasses dont get blinded by lighting their candle with a welding tool
			light("<span class='warning'>[user] casually lights the [name] with [W].</span>")
	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light()
	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit)
			light()
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light()

/obj/item/candle/get_current_temperature()
	if(lit)
		return 1000
	else
		return 0

/obj/item/candle/extinguish()
	var/obj/item/candle/C = new faded_candle(loc)
	if(istype(loc, /mob))
		var/mob/M = loc
		M.drop_from_inventory(src, null)
		M.put_in_hands(C)

	qdel(src)

/obj/item/candle/process()
	if(!lit)
		return
	if(!infinite)
		wax--
	if(!wax)
		extinguish()
		return
	update_icon()
	if(istype(loc, /turf)) // start a fire if possible
		var/turf/T = loc
		T.hotspot_expose(700, 5)

/obj/item/candle/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] blows out the [src].</span>")
		lit = FALSE
		update_icon()
		set_light(0)
		STOP_PROCESSING(SSobj, src)

 // Ghost candle
/obj/item/candle/ghost
	name = "black candle"

	icon_state = "black_candle"
	item_state = "black_candle"

	light_color = LIGHT_COLOR_GHOST_CANDLE

	faded_candle = /obj/item/trash/candle/ghost

/obj/item/candle/ghost/atom_init()
	. = ..()
	ghost_candles += src

/obj/item/candle/ghost/Destroy()
	ghost_candles -= src
	return ..()

/obj/item/candle/ghost/attack_ghost()
	if(!lit)
		src.light("<span class='warning'>\The [name] suddenly lights up.</span>")
		if(prob(10))
			spook()

/obj/item/candle/ghost/attack_self(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'>You can't just extinguish it.</span>")

/obj/item/candle/ghost/proc/spook()
	visible_message("<span class='warning bold'>Out of the tip of the flame, a face appears.</span>")
	playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	for(var/mob/living/carbon/M in hearers(4, get_turf(src)))
		if(!iscultist(M))
			M.confused += 10
			M.make_jittery(150)
	for(var/obj/machinery/light/L in range(4, get_turf(src)))
		L.on = TRUE
		L.broken()

/obj/item/candle/ghost/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	..()
	if(istype(W, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = W
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
	if(istype(W, /obj/item/weapon/book/tome))
		spook()
		light()
	if(user.getBrainLoss() >= 60 || user.mind.holy_role || user.mind.role_alt_title == "Paranormal Investigator")
		if(!lit && istype(W, /obj/item/weapon/storage/bible))
			var/obj/item/weapon/storage/bible/B = W
			if(B.icon_state == "necronomicon")
				spook()
				light()
			else
				for(var/mob/living/carbon/M in range(4, src))
					to_chat(M, "<span class='notice'>You feel slight delight, as all curses pass away...</span>")
					M.apply_damages(-1,-1,-1,-1,0,0)
					light()
		if(istype(W, /obj/item/weapon/nullrod))
			var/obj/item/candle/C = new /obj/item/candle(loc)
			if(lit)
				C.light("")
			C.wax = wax
			if(istype(loc, /mob))
				user.put_in_hands(C)
			qdel(src)
		if(istype(W, /obj/item/trash/candle))
			to_chat(user, "<span class='warning'>The wax begins to corrupt and pulse like veins as it merges itself with the [src], impressive.</span>")
			user.confused += 10 // Sights of this are not pleasant.
			if(prob(10))
				user.invoke_vomit_async()
			wax += 50
			user.drop_item()
			qdel(W)

/obj/item/candle/red
	name = "red candle"

	icon_state = "red_candle"
	item_state = "red_candle"

	faded_candle = /obj/item/trash/candle/red

 // Infinite candle (Admin item)
/obj/item/candle/infinite
	infinite = TRUE
	start_lit = TRUE

/obj/item/candle/chandelier
	name = "Chandelier"

	icon_state = "chandelier"
	item_state = "chandelier"

	w_class = ITEM_SIZE_NORMAL

	var/count_candles = 0

	// ref on candle in chandelier
	var/list/obj/item/candle/candles = list(
		"left" = null,
		"central" = null,
		"right" = null,
	)

	var/list/place = list("left", "central", "right")

/obj/item/candle/chandelier/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/candle))
		for(var/i in place)
			if(!candles[i])
				var/obj/item/candle/C = W
				candles[i] = C
				usr.remove_from_mob(C)
				C.loc = src
				var/lightning_stage = calculate_lighting_stage(C.wax)
				add_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage][C.lit ? "_lit" : ""]"))
				break
	else
		for(var/i in place)
			if(candles[i])
				count_candles += 1
				var/obj/item/candle/candle = candles[i]
				if(candle.lit)
					continue
				if(iswelder(W))
					var/obj/item/weapon/weldingtool/WT = W
					if(WT.isOn())
						candle.light("<span class='warning'>[user] casually lights the [name] with [W].</span>")
						set_light(CANDLE_LUMINOSITY, count_candles)
						break
				else if(istype(W, /obj/item/weapon/lighter))
					var/obj/item/weapon/lighter/L = W
					if(L.lit)
						candle.light()
						set_light(CANDLE_LUMINOSITY, count_candles)
						break
				else if(istype(W, /obj/item/weapon/match))
					var/obj/item/weapon/match/M = W
					if(M.lit)
						candle.light()
						set_light(CANDLE_LUMINOSITY, count_candles)
						break
				else if(istype(W, /obj/item/candle))
					var/obj/item/candle/C = W
					if(C.lit)
						candle.light()
						set_light(CANDLE_LUMINOSITY, count_candles)
						break

/obj/item/candle/chandelier/attack_self(mob/living/carbon/human/user)
	for(var/i in place)
		if(candles[i])
			var/obj/item/candle/C = candles[i]
			var/lightning_stage = calculate_lighting_stage(C.wax)
			count_candles -= 1
			cut_overlay(image('icons/obj/candle.dmi', "[i]_[lightning_stage][C.lit ? "_lit" : ""]"))
			set_light(CANDLE_LUMINOSITY, count_candles)
			user.put_in_hands(C)
			candles[i] = null
			break

/obj/item/candle/chandelier/process()
	if(!candles["left"] && !candles["central"] && !candles["right"])
		return
	update_icon()

/obj/item/candle/chandelier/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/candle/chandelier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

#undef CANDLE_LUMINOSITY
