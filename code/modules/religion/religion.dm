/*
	This datum is used to neatly package all of chaplain's choices and etc
	and save them somewhere for future reference.
*/

// Create a religion. You must declare proc/setup_religions() of religion
/proc/create_religion(type)
	new type

/datum/religion
	// The name of this religion.
	var/name = ""
	// Lore of this religion. Is displayed to "God(s)". If none is set, chaplain will be prompted to set up their own lore.
	var/lore = ""
	var/list/lore_by_name = list()

	// List of names of deities of this religion.
	// There is no "default" deity, please specify one for your religion here.
	var/list/deity_names = list()
	var/list/deity_names_by_name

	// Default is /datum/bible_info/custom, if one is not specified here.
	var/datum/bible_info/bible_info
	var/list/bible_info_by_name
	// Radial menu
	var/list/bible_skins

	/*
	var/lecturn_icon_state
	// Is required to have a "Default" as a fallback.
	var/static/list/lecturn_info_by_name = list(
	)

	// Radial menu
	var/lecturn_skins
	*/

	var/pews_icon_state
	var/list/pews_info_by_name
	// Radial menu
	var/list/pews_skins

	var/altar_icon_state
	// Is required to have a "Default" as a fallback.
	var/list/altar_info_by_name
	// Radial menu
	var/list/altar_skins

	// Default is "0" TO-DO: convert this to icon_states. ~Luduk
	var/carpet_dir
	var/list/carpet_dir_by_name
	// Radial menu
	var/list/carpet_skins

	var/list/area_types

	/*
		Aspects and Rites related
	*/
	var/list/active_deities = list()

	// The religion's 'Mana'
	var/favor = 0
	// The max amount of favor the religion can have
	var/max_favor = 3000
	// The amount of favor generated passively
	var/passive_favor_gain = 0.0

	// More important than favor, used in very expensive rites
	var/piety = 0

	// Chosen aspects.
	var/list/aspects = list()
	// Spells that are determined by aspect combinations, are given to God.
	var/list/god_spells = list()
	// Lists of rites with information. Converts itself into a list of rites with "name - desc (favor_cost)"
	var/list/rites_info = list()
	// Lists of rite name by type. "name = rite"
	var/list/rites_by_name = list()

	// Contains an altar, wherever it is
	var/obj/structure/altar_of_gods/altar

	// The whole composition of beings in religion
	var/list/members = list()

	// All constructions that religion can build
	var/list/datum/building_agent/available_buildings = list()
	// Type of initial construction agent for which available_buildings will be generated
	var/agent_type

	// A list of ids of holy reagents from aspects.
	var/list/holy_reagents = list()
	// A list of possible faith reactions.
	var/list/faith_reactions = list()

	// A dict of holy turfs of format holy_turf = timer_id.
	var/list/holy_turfs = list()

/datum/religion/New()
	reset_religion()
	setup_religions()

/datum/religion/process()
	if(passive_favor_gain == 0.0)
		STOP_PROCESSING(SSreligion, src)
		return

	adjust_favor(passive_favor_gain)

// This proc is called from tickers setup, right after economy is done, but before any characters are spawned.
/datum/religion/proc/setup_religions()
	return

/datum/religion/proc/reset_religion()
	lore = initial(lore)
	lore_by_name = list()
	deity_names = list()
	bible_info = initial(bible_info)
	for(var/god in active_deities)
		remove_deity(god)
	favor = initial(favor)
	max_favor = initial(max_favor)
	aspects = list()
	god_spells = list()
	rites_info = list()
	rites_by_name = list()
	members = list()

	if(altar)
		altar.chosen_aspect = initial(altar.chosen_aspect)
		altar.sect = initial(altar.sect)
		altar.religion = initial(altar.religion)
		altar.performing_rite = initial(altar.performing_rite)

	create_default()

/datum/religion/Destroy()
	QDEL_LIST_ASSOC_VAL(holy_turfs)
	holy_turfs = null

	altar = null
	return ..()

/datum/religion/proc/gen_bible_info()
	if(bible_info_by_name[name])
		var/info_type = bible_info_by_name[name]
		bible_info = new info_type(src)
	else
		bible_info = new /datum/bible_info/custom(src)

/datum/religion/proc/gen_altar_variants()
	altar_skins = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/info in altar_info_by_name)
		var/image/I = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = altar_info_by_name[info])
		I.transform = M
		altar_skins[info] = I

/datum/religion/proc/gen_pews_variants()
	pews_skins = list()
	for(var/info in pews_info_by_name)
		pews_skins[info] = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "[pews_info_by_name[info]]_left")

/datum/religion/proc/gen_carpet_variants()
	carpet_skins = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/info in carpet_dir_by_name)
		var/image/I = image(icon = 'icons/turf/carpets.dmi', icon_state = "carpetsymbol", dir = carpet_dir_by_name[info])
		I.transform = M
		carpet_skins[info] = I

// This proc creates a "preset" of religion, before allowing to fill out the details.
/datum/religion/proc/create_default()
	name = pick(DEFAULT_RELIGION_NAMES)

	lore = lore_by_name[name]
	if(!lore)
		lore = ""

	deity_names = deity_names_by_name[name]
	if(!deity_names)
		warning("ERROR IN SETTING UP RELIGION: [name] HAS NO DEITIES WHATSOVER. HAVE YOU SET UP RELIGIONS CORRECTLY?")
		deity_names = list("Error")

	gen_bible_info()
	gen_altar_variants()
	gen_pews_variants()
	gen_carpet_variants()

	gen_building_list()

	update_structure_info()

// Update all info regarding structure based on current religion info.
/datum/religion/proc/update_structure_info()
	var/carpet_dir = carpet_dir_by_name[name]
	if(!carpet_dir)
		carpet_dir = 0

	/*
	var/lecturn_info = lecturn_info_by_name[name]
	if(lecturn_info)
		lecturn_icon_state = lecturn_info
	else
		lecturn_info_state = lecturn_info_by_name["Default"]
	*/

	var/pews_info = pews_info_by_name[name]
	if(pews_info)
		pews_icon_state = pews_info
	else
		pews_icon_state = pews_info_by_name["Default"]

	var/altar_info = altar_info_by_name[name]
	if(altar_info)
		altar_icon_state = altar_info
	else
		altar_icon_state = altar_info_by_name["Default"]

// This proc converts all related objects in areatype to this reigion's liking.
/datum/religion/proc/religify()
	var/list/to_religify = get_area_all_atoms(area_types)
	for(var/atom/A in to_religify)
		if(istype(A, /turf/simulated/floor) && A.icon_state == "carpetsymbol")
			A.dir = carpet_dir
		else if(istype(A, /obj/structure/stool/bed/chair/pew))
			var/obj/structure/stool/bed/chair/pew/P = A
			P.pew_icon = pews_icon_state
			P.update_icon()
		else if(istype(A, /obj/structure/altar_of_gods))
			var/obj/structure/altar_of_gods/G = A
			G.icon_state = altar_icon_state
			G.update_icon()

// This proc returns a bible object of this religion, spawning it at a given location.
/datum/religion/proc/spawn_bible(atom/location, bible_type = /obj/item/weapon/storage/bible)
	var/obj/item/weapon/storage/bible/B = new bible_type(location)
	bible_info.apply_to(B)
	B.deity_name = pick(deity_names)
	B.god_lore = lore
	B.religion = src
	return B

// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion/proc/adjust_favor(amount = 0, mob/living/L)
	. = amount
	piety += amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if(favor + amount > max_favor)
		. = (max_favor - favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = between(0, favor + amount,  max_favor)

// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion/proc/set_favor(amount = 0, mob/living/L)
	favor = between(0, amount, max_favor)
	return favor

// This predicate is used to determine whether this religion meets spells/rites aspect requirements.
// Is used in is_sublist_assoc
/datum/religion/proc/satisfy_requirements(element, datum/aspect/A)
	return element <= A.power

// This proc is used to change divine power of a spell according to this religion's aspects.
// Uses a form of this formula:
// power = power * (summ of aspect diferences / amount of spell aspects + 1)
/datum/religion/proc/affect_divine_power(obj/effect/proc_holder/spell/S)
	var/divine_power = initial(S.divine_power)

	var/diff = 0

	for(var/aspect_name in aspects)
		var/datum/aspect/asp = aspects[aspect_name]
		if(S.needed_aspect[asp.name])
			diff += asp.power - S.needed_aspect[asp.name]

	S.divine_power = divine_power * (diff / S.needed_aspect.len + 1)

// Give our gods all needed spells which in /list/spells
/datum/religion/proc/give_god_spells(mob/G)
	for(var/spell in god_spells)
		var/obj/effect/proc_holder/spell/S = G.GetSpell(spell)
		if(S)
			affect_divine_power(S)
			continue
		else
			S = new spell
			affect_divine_power(S)
			G.AddSpell(S)

/datum/religion/proc/remove_god_spells(mob/G)
	G.ClearSpells()

/datum/religion/proc/update_deities()
	for(var/mob/deity in active_deities)
		give_god_spells(deity)

// Generate new rite_list
/datum/religion/proc/update_rites()
	if(rites_by_name.len > 0)
		rites_info = list()
		// Generates a list of information of rite, used for examine() in altar_of_gods
		for(var/i in rites_by_name)
			var/datum/religion_rites/RI = rites_by_name[i]
			var/name_entry = ""

			var/tip_text
			for(var/tip in RI.tips)
				if(tip_text)
					tip_text += " "
				tip_text += tip
			if(tip_text)
				name_entry += "[EMBED_TIP(RI.name, tip_text)]"
			else
				name_entry += "[RI.name]"

			if(RI.desc)
				name_entry += " - [RI.desc]"
			if(RI.favor_cost)
				name_entry += " ([RI.favor_cost] favor)"
			if(RI.piety_cost)
				altar.look_piety = TRUE
				name_entry += "<span class='piety'> ([RI.piety_cost] piety)</span>"

			rites_info += "[name_entry]"

// Adds all spells related to asp.
/datum/religion/proc/add_aspect_spells(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/spell_type in global.spells_by_aspects[asp.name])
		var/obj/effect/proc_holder/spell/S = new spell_type

		if(is_sublist_assoc(S.needed_aspect, aspects, aspect_pred))
			god_spells |= spell_type

		QDEL_NULL(S)

// Adds all rites related to asp.
/datum/religion/proc/add_aspect_rites(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/rite_type in global.rites_by_aspects[asp.name])
		var/datum/religion_rites/RR = new rite_type

		if(rites_by_name[RR.name])
			continue

		if(is_sublist_assoc(RR.needed_aspects, aspects, aspect_pred))
			var/datum/religion_rites/R = new rite_type
			R.religion = src
			rites_by_name[RR.name] = R

		QDEL_NULL(RR)

/datum/religion/proc/add_aspect_reagents(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/reagent_id in global.holy_reagents_by_aspects[asp.name])
		var/datum/reagent/R = global.chemical_reagents_list[reagent_id]

		if(is_sublist_assoc(R.needed_aspects, aspects, aspect_pred))
			holy_reagents[R.name] = reagent_id

	for(var/reaction_id in global.faith_reactions_by_aspects[asp.name])
		var/datum/faith_reaction/FR = global.faith_reactions[reaction_id]

		if(is_sublist_assoc(FR.needed_aspects, aspects, aspect_pred))
			faith_reactions[FR.id] = FR

// Is called after any addition of new aspects.
// Manages new spells and rites, gained by adding the new aspects.
/datum/religion/proc/update_aspects()
	var/datum/callback/aspect_pred = CALLBACK(src, .proc/satisfy_requirements)

	for(var/aspect_name in aspects)
		var/datum/aspect/asp = aspects[aspect_name]
		add_aspect_spells(asp, aspect_pred)
		add_aspect_rites(asp, aspect_pred)
		add_aspect_reagents(asp, aspect_pred)

	update_deities()
	update_rites()

// This proc is used to handle addition of aspects properly.
// It expects aspect_list to be of form list(aspect_type = aspect power)
/datum/religion/proc/add_aspects(list/aspect_list)
	for(var/aspect_type in aspect_list)
		var/datum/aspect/asp = aspect_type
		if(aspects[initial(asp.name)])
			var/datum/aspect/aspect = aspects[initial(asp.name)]
			aspect.power += aspect_list[aspect_type]
		else
			var/datum/aspect/aspect = new aspect_type
			aspect.power = aspect_list[aspect_type]
			aspects[aspect.name] = aspect

	update_aspects()

/datum/religion/proc/add_deity(mob/M)
	active_deities += M
	M.mind.my_religion = src
	give_god_spells(M)

/datum/religion/proc/remove_deity(mob/M)
	active_deities -= M
	M.mind.my_religion = null
	remove_god_spells(M)

/datum/religion/proc/add_member(mob/M, holy_role)
	if(M in members)
		return FALSE

	members |= M
	M.mind.my_religion = src
	M.mind.holy_role = holy_role
	return TRUE

/datum/religion/proc/remove_member(mob/M)
	if(!(M in members))
		return FALSE

	members -= M
	M.mind.my_religion = null
	M.mind.holy_role = initial(M.mind.holy_role)
	return TRUE

/datum/religion/proc/gen_building_list()
	init_subtypes(agent_type, available_buildings)

/datum/religion/proc/on_holy_reagent_created(datum/reagent/R)
	RegisterSignal(R, list(COMSIG_REAGENT_REACTION_TURF), .proc/holy_reagent_react_turf)

/datum/religion/proc/holy_reagent_react_turf(datum/source, turf/T, volume)
	if(!istype(T, /turf/simulated/floor))
		return

	add_holy_turf(T, volume)

/datum/religion/proc/add_holy_turf(turf/simulated/floor/F, volume)
	if(holy_turfs[F])
		var/datum/holy_turf/HT = holy_turfs[F]
		HT.update(volume)
		return
	holy_turfs[F] = new /datum/holy_turf(F, src, volume)

/datum/religion/proc/remove_holy_turf(turf/simulated/floor/F)
	qdel(holy_turfs[F])
