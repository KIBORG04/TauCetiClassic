/datum/role/abductor
	disallow_job = TRUE
	required_pref = ROLE_ABDUCTOR

	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductor"

/datum/role/abductor/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'><B>You are an <font color='red'>[name]</font> of [faction.name]!</B></span>")
	to_chat(antag.current, "<span class='info'>With the help of your teammate, kidnap and experiment on station crew members!</span>")

	return TRUE

/datum/role/abductor/proc/equip_common()
	var/mob/living/carbon/human/agent = antag.current
	var/radio_freq = SYND_FREQ
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
	R.set_frequency(radio_freq)
	agent.equip_to_slot_or_del(R, SLOT_L_EAR)
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(agent), SLOT_SHOES)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), SLOT_W_UNIFORM) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), SLOT_BACK)

/datum/role/abductor/proc/equip_class()
	return

/datum/role/abductor/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/abductor/H = antag.current
	H.set_species(ABDUCTOR)
	H.real_name = faction.name + " Agent"
	H.mind.name = H.real_name
	H.flavor_text = ""
	equip_common(H)
	equip_class()
	H.regenerate_icons()

	return TRUE

/datum/role/abductor/proc/get_team_num()
	var/datum/faction/abductors/A = faction
	return A.team_number

/datum/role/abductor/agent
	name = "Agent"
	id = ABDUCTOR_AGENT
	special_role = ABDUCTOR_AGENT

/datum/role/abductor/agent/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	return TRUE

/datum/role/abductor/agent/equip_class()
	var/mob/living/carbon/human/agent = antag.current
	var/datum/faction/abductors/A = faction

	var/obj/machinery/abductor/console/console = A.get_team_console()
	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(agent)
	if(console!=null)
		console.vest = V
	agent.equip_to_slot_or_del(V, SLOT_WEAR_SUIT)
	agent.equip_to_slot_or_del(new /obj/item/weapon/abductor_baton(agent), SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/decloner/alien(agent), SLOT_BELT)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), SLOT_HEAD)

/datum/role/abductor/agent/OnPostSetup(laterole)
	. = ..()

	var/datum/faction/abductors/A = faction
	var/obj/effect/landmark/L = agent_landmarks[A.team_number]
	antag.current.forceMove(L.loc)

	return TRUE

/datum/role/abductor/scientist
	name = "Scientist"
	id = ABDUCTOR_SCI
	special_role = ABDUCTOR_SCI

/datum/role/abductor/scientist/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")

	return TRUE

/datum/role/abductor/scientist/equip_class()
	var/mob/living/carbon/human/scientist = antag.current
	var/datum/faction/abductors/A = faction

	var/obj/machinery/abductor/console/console = A.get_team_console()
	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(scientist)
	if(console != null)
		console.gizmo = G
		G.console = console
	scientist.equip_to_slot_or_del(G, SLOT_IN_BACKPACK)
	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(scientist)
	beamplant.imp_in = scientist
	beamplant.implanted = 1
	beamplant.implanted(scientist)
	beamplant.home = console.pad

/datum/role/abductor/scientist/OnPostSetup(laterole)
	. = ..()

	var/datum/faction/abductors/A = faction
	var/obj/effect/landmark/L = scientist_landmarks[A.team_number]
	antag.current.forceMove(L.loc)

	return TRUE
/datum/role/abducted
	name = ABDUCTED
	id = ABDUCTED
	special_role = ABDUCTED
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductee"

/datum/role/abducted/forgeObjectives()
	AppendObjective(pick(typesof(/datum/objective/abductee) - /datum/objective/abductee))
