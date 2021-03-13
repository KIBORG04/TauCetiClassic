
/datum/role/syndicate/operative/proc/NukeNameAssign(datum/mind/synd_mind)
	var/choose_name = sanitize_safe(input(synd_mind.current, "You are a Gorlex Maradeurs agent! What is your name?", "Choose a name") as text, MAX_NAME_LEN)

	if(!choose_name)
		return

	synd_mind.current.name = choose_name
	synd_mind.current.real_name = choose_name

/datum/role/syndicate/operative
	name = NUKE_OP
	id = NUKE_OP
	special_role = NUKE_OP
	disallow_job = TRUE

	required_pref = ROLE_OPERATIVE

	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudsyndicate"

	logo_state = "nuke-logo"

	var/nuclear_outfit = /datum/outfit/nuclear

/datum/role/syndicate/operative/OnPostSetup(laterole)
	. = ..()
	antag.current.faction = "syndicate"
	antag.current.real_name = "Gorlex Maradeurs Operative"

	if(ishuman(antag.current))
		var/mob/living/carbon/human/H = antag.current
		H.equipOutfit(nuclear_outfit)
	antag.current.add_language("Sy-Code")

	INVOKE_ASYNC(src, .proc/NukeNameAssign, antag)

/datum/role/syndicate/operative/forgeObjectives()
	AppendObjective(/datum/objective/nuclear)

/datum/role/syndicate/operative/Greet(greeting, custom)
	. = ..()
	antag.current.playsound_local(null, 'sound/antag/ops.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/role/syndicate/operative/extraPanelButtons()
	var/dat = ""
	dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];nuke_tp=1;'>Tp to base!</a><br>"
	dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];nuke_tellcode=1'>Tell code</a><br>"
	return dat

/datum/role/syndicate/operative/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["nuke_tp"])
		antag.current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))

	else if(href_list["nuke_tellcode"])
		var/code
		for (var/obj/machinery/nuclearbomb/bombue in poi_list)
			if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
				code = bombue.r_code
				break
		if (code)
			antag.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0)
			to_chat(antag.current, "The nuclear authorization code is: <B>[code]</B>")
		else
			to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

/datum/role/syndicate/operative/leader
	name = NUKE_OP_LEADER
	id = NUKE_OP_LEADER
	special_role = NUKE_OP_LEADER

	nuclear_outfit = /datum/outfit/nuclear/leader

/datum/role/syndicate/operative/leader/OnPostSetup(laterole)
	. = ..()
	var/datum/faction/nuclear/N = faction
	if (N.nuke_code)
		antag.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [N.nuke_code]", 0)
		to_chat(antag.current, "The nuclear authorization code is: <B>[N.nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[N.nuke_code]</b>"
		P.name = "nuclear bomb code"
		P.update_icon()
		var/mob/living/carbon/human/H = antag.current
		P.loc = H.loc
		H.equip_to_slot_or_del(P, SLOT_R_STORE, 0)
		H.update_icons()
