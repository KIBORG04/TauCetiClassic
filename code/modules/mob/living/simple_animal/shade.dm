/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	universal_speak = 1
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches the"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = "cult"
	status_flags = CANPUSH

	animalistic = FALSE

/mob/living/simple_animal/shade/Life()
	..()
	if(stat == DEAD)
		new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(loc)
		visible_message("<span class='warning'>[src] lets out a contented sigh as their form unwinds.</span>")
		ghostize(bancheck = TRUE)
		qdel(src)
		return


/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			visible_message("<span class='warning'><b>[src] has been attacked with the [O] by [user].</b></span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			visible_message("<span class='warning'>[user] gently taps [src] with the [O].</span>")
	return

/mob/living/simple_animal/shade/god
	name = "Unbelievable God"
	real_name = "Unbelievable God"
	desc = "Strange looking hologram."
	icon_state = "shade_god"
	icon_living = "shade_god"
	stat = CONSCIOUS
	speak_emote = list("hisses", "bless")
	maxHealth = 5000
	health = 5000
	melee_damage_lower = 0
	melee_damage_upper = 0
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
