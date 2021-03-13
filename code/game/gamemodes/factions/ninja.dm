/datum/faction/ninja
	name = SPIDERCLAN
	ID = SPIDERCLAN

	initial_role = NINJA
	late_role = NINJA
	initroletype = /datum/role/ninja

	max_roles = 2

	required_pref = ROLE_NINJA

	logo_state = "ninja-logo"

	var/finished = FALSE

/datum/faction/ninja/can_setup(num_players)
	if (!..())
		return FALSE
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "ninja")
			return TRUE
	return FALSE

/datum/faction/ninja/OnPostSetup()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "ninja")
			ninjastart.Add(L)
	for(var/datum/role/role in members)
		var/start_point = pick(ninjastart)
		ninjastart -= start_point
		role.antag.current.forceMove(start_point)
	return ..()

/datum/faction/ninja/check_win()
	. = ..()
	if(config.continous_rounds)
		return FALSE
	var/ninjas_alive = 0
	for(var/datum/role/ninja_role in members)
		if(!istype(ninja_role.antag.current, /mob/living/carbon/human))
			continue
		if(ninja_role.antag.current.stat==2)
			continue
		ninjas_alive++
	if(ninjas_alive)
		return FALSE
	else
		finished = 1
		return TRUE
