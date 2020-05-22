/*
 * Food summoning
 * Grants a lot of food while you AFK near the altar. Even more food if you finish the ritual.
 */
/datum/religion_rites/food
	name = "Create food"
	desc = "Create more and more food!"
	ritual_length = (2.2 MINUTES)
	ritual_invocations = list("O Lord, we pray to you: hear our prayer, that they may be delivered by thy mercy, for the glory of thy name...",
						"...our crops and gardens, now it's fair for our sins that are destroyed and a real disaster is suffered, from birds, worms, mice, moles and other animals...",
						"...and driven far away from this place by Your authority, may they not harm anyone, but these fields and waters...",
						"...and the gardens will be left completely at rest so that all that is growing and born in them will serve for thy glory...",
						"...and our needs helped, for we praise you...")
	invoke_msg = "...and bring glory to you!!"
	favor_cost = 300

	needed_aspects = list(
		ASPECT_FOOD = 1,
	)

// This proc is also used by spells/religion.dm "spawn food". Stupid architecture, gotta deal with it some time ~Luduk
// Perhaps allow God to do rituals instead? ~Luduk
/proc/spawn_food(atom/location, amount)
	var/static/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food)

	playsound(location, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/i in 1 to amount)
		var/chosen = pick(borks)
		var/obj/B = new chosen(location)
		var/obj/randomcatcher/CATCH
		if(!B.icon_state || !B.reagents || !B.reagents.reagent_list.len)
			QDEL_NULL(B)
			CATCH = new /obj/randomcatcher(location)
			B = CATCH.get_item(pick(/obj/random/foods/drink_can, /obj/random/foods/drink_bottle, /obj/random/foods/food_snack, /obj/random/foods/food_without_garbage))
			QDEL_NULL(CATCH)
		if(B && prob(80))
			for(var/j in 1 to rand(1, 3))
				step(B, pick(NORTH, SOUTH, EAST, WEST))

/datum/religion_rites/food/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(AOG.loc, 4 + rand(2, 5))

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/food/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(prob(50))
		spawn_food(AOG.loc, 1)
	return TRUE

/*
 * Prayer
 * Increases favour while you AFK near altar, heals everybody around if invoked succesfully.
 */
/datum/religion_rites/pray
	name = "Prayer to god"
	desc = "Pray for a while in exchange for favor."
	ritual_length = (4 MINUTES)
	ritual_invocations = list("Have mercy on us, O Lord, have mercy on us...",
							  "...for at a loss for any defense, this prayer do we sinners offer Thee as Master...",
							  "...have mercy on us...",
							  "...Lord have mercy on us, for we have hoped in Thee, be not angry with us greatly, neither remember our iniquities...",
							  "...but look upon us now as Thou art compassionate, and deliver us from our enemies...",
							  "...for Thou art our God, and we, Thy people; all are the works of Thy hands, and we call upon Thy name...",
							  "...Both now and ever, and unto the ages of ages...",
							  "...The door of compassion open unto us 0 blessed Theotokos, for hoping in thee...",
							  "...let us not perish; through thee may we be delivered from adversities, for thou art the salvation of the Our race...")
	invoke_msg = "Lord have mercy. Twelve times."
	favor_cost = 0

	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/pray/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/heal_num = -15
	for(var/mob/living/L in range(2, src))
		L.apply_damages(heal_num, heal_num, heal_num, heal_num, heal_num, heal_num)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/pray/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	global.chaplain_religion.favor += 20
	return TRUE

/*
 * Honk
 * The ritual creates a honk that everyone hears.
 */
/datum/religion_rites/honk
	name = "Clown shriek"
	desc = "Spread honks throughout the station."
	ritual_length = (2 MINUTES)
	ritual_invocations = list("All able to hear, hear!...",
							  "...This message is dedicated to all of you...",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns...",)
	invoke_msg = "...So hear it!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_WACKY = 1,
	)

/datum/religion_rites/honk/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/items/AirHorn.ogg', VOL_EFFECTS_MASTER, null, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/honk/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	var/ratio = (100 / ritual_invocations.len) * stage
	playsound(AOG, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC, ratio)
	return TRUE

/*
 * Revitalizing items.
 * It makes a thing move and say something. You can't pick up a thing until you kill a item-mob.
 */
/datum/religion_rites/animation
	name = "Animation"
	desc = "Revives a things on the altar."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("I appeal to you - you are the strength of the Lord...",
							  "...given from the light given by the wisdom of the gods returned...",
							  "...They endowed Animation with human passions and feelings...",
							  "...Animation, come from the New Kingdom, rejoice in the light!...",)
	invoke_msg = "I appeal to you! I am calling! Wake up from sleep!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_WEAPON = 1,
		ASPECT_SPAWN = 1,
	)

/datum/religion_rites/animation/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/obj/item/anim_item = locate() in AOG.loc
	if(!anim_item)
		to_chat(user, "<span class='warning'>Put any the item on the altar!</span>")
		return FALSE
	return TRUE

/datum/religion_rites/animation/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE

	var/list/anim_items = list()
	for(var/obj/item/O in AOG.loc)
		anim_items += O

	if(anim_items && anim_items.len != 0)
		for(var/obj/item/O in anim_items)
			new /mob/living/simple_animal/hostile/mimic/copy/religion(O.loc, O)

	user.visible_message("<span class='notice'>[user] has been finished the rite of [name]!</span>")
	return TRUE

/*
 * Spook
 * This ritual spooks players: Light lamps pop out, and people start to shake
 */
/datum/religion_rites/spook
	name = "Spook"
	desc = "Distributes a jerky sound."
	ritual_length = (30 SECONDS)
	ritual_invocations = list("I call the souls of people here, I send your soul to the otherworldly thief, in a black mirror...",
							  "...Let Evil take you and lock you up...",
							  "...torment you, torture you, torture you all, exhaust you, destroy you...",
							  "...I give evil to your soul...",
							  "...I instill Evil in your head, in your heart, in your liver, in your blood...",
							  "...I do not order...",
							  "...As I said, it will be so! I close with a key, close with a lock...")
	invoke_msg = "...I conjure! I conjure! I conjure!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_OBSCURE = 1,
	)

/datum/religion_rites/spook/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	for(var/mob/living/carbon/M in hearers(4, get_turf(AOG)))
		if(M.mind.holy_role)
			M.make_jittery(50)
		else
			M.confused += 10
			M.make_jittery(50)
			if(prob(50))
				M.visible_message("<span class='warning bold'>[M]'s face clearly depicts true fear.</span>")

	var/list/targets = list()
	for(var/turf/T in range(4))
		targets += T
	light_off_range(targets, AOG)

	return TRUE

/*
 * Illuminate
 * The ritual turns on the flash in range, create overlay of "spirit" and the person begins to glow
 */
/datum/religion_rites/illuminate
	name = "Illuminate"
	desc = "Create wisp of light and turns on the light."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Come to me, wisp...",
							  "...Appear to me the one whom everyone wants...",
							  "...to whom they turn for help!..",
							  "...Good wisp, able to reveal the darkness...",
							  "...I ask you for help...",
							  "...Hear me, do not reject me...",
							  "...for it's not just for the sake of curiosity that I disturb your peace...")
	invoke_msg = "...I pray, please come!"
	favor_cost = 200

	var/shield_icon = "at_shield2"

	needed_aspects = list(
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/illuminate/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/mob/living/carbon/human/H in range(3, get_turf(AOG)))
		for(var/obj/item/device/flashlight/F in H.contents)
			if(is_type_in_list(F, blacklisted_lights))
				continue
			if(F.brightness_on)
				if(!F.on)
					F.on = !F.on
					F.icon_state = "[initial(F.icon_state)]-on"
					F.set_light(F.brightness_on)

	for(var/obj/item/device/flashlight/F in range(3, get_turf(AOG)))
		if(F.brightness_on)
			if(!F.on)
				F.on = !F.on
				F.icon_state = "[initial(F.icon_state)]-on"
				F.set_light(F.brightness_on)

	var/image/I = image('icons/effects/effects.dmi', icon_state = shield_icon, layer = MOB_LAYER + 0.01)
	var/matrix/M = matrix(I.transform)
	M.Scale(0.3)
	I.alpha = 150
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.transform = M
	I.pixel_x = 12	
	I.pixel_y = 12
	user.add_overlay(I)
	user.set_light(7)
	return TRUE

/*
 * Revive
 * Revive animal
 */
/datum/religion_rites/revive_animal
	name = "Revive"
	desc = "The animal revives from the better world."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("I will say, whisper, quietly say such words...",
							  "...May every disease leave you...",
							  "...You will not know that you are in torment, pain and suffering...",
							  "...No one can hurt...",
							  "...You must poison the whole, chase the tails from the body a animal...",
							  "... let them go to the raw ground, the water goes and does not come back...",
							  "...God helps, and in my words the work is strengthened...",)
	invoke_msg = "...Let it be so!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/revive_animal/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(!isanimal(AOG.buckled_mob))
		var/mob/living/simple_animal/S = AOG.buckled_mob
		if(!S.animalistic)
			to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
			return FALSE
	return TRUE

/datum/religion_rites/revive_animal/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE

	var/mob/living/simple_animal/animal = AOG.buckled_mob
	if(!istype(animal))
		return FALSE

	animal.rejuvenate()

	return TRUE

/*
 * Create random friendly animal
 * AoE relocor items
 */
/datum/religion_rites/call_animal
	name = "Call animal"
	desc = "Create random friendly animal."
	ritual_length = (1.5 MINUTES)
	ritual_invocations = list("As these complex nodules of the world are interconnected...",
						"...so even my animal will be connected with this place...",
						"...My will has allowed me to create and call you to life...",
						"...Your existence is limited to fulfilling your goal...",
						"...Let you come here...")
	invoke_msg = "...Let it be so!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
	)

	var/list/summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/datum/religion_rites/call_animal/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	var/type = pick(summon_type)
	var/mob/M = new type(AOG.loc)

	for(var/mob/dead/observer/O in observer_list)
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_GHOSTLY) && role_available_in_minutes(O, ROLE_GHOSTLY))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find(IGNORE_FAMILIAR) && (ROLE_GHOSTLY in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C, M)
	return TRUE

/datum/religion_rites/call_animal/proc/question(client/C, mob/M)
	if(!C)
		return
	var/response = alert(C, "Do you want to become the Familiar of religion?", "Familiar request", "No", "Yes", "Never for this round")
	if(!C || M.ckey)
		return //handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yes")
		var/mob/candidate = C.mob
		var/god_name
		if(global.chaplain_religion.active_deities.len == 0)
			god_name = pick(global.chaplain_religion.deity_names)
		else
			var/mob/god = pick(global.chaplain_religion.active_deities)
			god_name = god.name
		M.mind = candidate.mind
		M.ckey = candidate.ckey
		M.name = "familiar of [god_name] [num2roman(rand(1, 20))]"
		M.real_name = name
		candidate.cancel_camera()
		candidate.reset_view()
	else if (response == "Never for this round")
		C.prefs.ignore_question += IGNORE_FAMILIAR

/*
 * Create religious sword
 * Just create claymore with reduced damage.
 */
/datum/religion_rites/create_sword
	name = "Create sword"
	desc = "Creates a religious sword in the name of God."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("The Holy Spirit, who solves all problems, sheds light on all roads so that I can reach my goal...",
						"...You are giving me the Divine gift of forgiveness and the forgiveness of all evil done against me...",
						"...who abides with all the storms of life...",
						"...In this prayer, I want to thank you for everything...",
						"...looking for time to prove that I will never part with you...",
						"...despite any illusory matter...",
						"...I want to abide with you in your eternal glory...",
						"...I thank you for all your blessings to me and my neighbors...",)
	invoke_msg = "...Let it be so!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_WEAPON = 1
	)

/datum/religion_rites/create_sword/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	var/obj/item/weapon/claymore/religion/R = new (AOG.loc)
	var/god_name
	if(global.chaplain_religion.active_deities.len == 0)
		god_name = pick(global.chaplain_religion.deity_names)
	else
		var/mob/god = pick(global.chaplain_religion.active_deities)
		god_name = god.name
	R.name = "[R.name] of [god_name]"

	R.down_overlay = image('icons/effects/effects.dmi', icon_state = "at_shield2", layer = OBJ_LAYER - 0.01)
	R.down_overlay.alpha = 100
	R.add_overlay(R.down_overlay)
	addtimer(CALLBACK(R, /obj/item/weapon/claymore/religion.proc/revert_effect), 5 SECONDS)
	return TRUE
