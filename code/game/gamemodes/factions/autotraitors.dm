#define SPAWN_CD 15 MINUTES

/datum/faction/traitor/auto
	name = "AutoTraitors"
	accept_latejoiners = TRUE
	var/next_try = 0

/datum/faction/traitor/auto/can_setup(num_players)
	. = ..()

	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	if(config.traitor_scaling)
		max_roles = max_traitors - 1 + prob(traitor_prob)
		log_game("Number of traitors: [max_roles]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [max_roles]")
	else
		max_roles = max(1, min(num_players, traitors_possible))

	abandon_allowed = 1
	return TRUE

/datum/faction/traitor/auto/proc/traitorcheckloop()
	if(SSshuttle.departed)
		return

	if(SSshuttle.online) //shuttle in the way, but may be revoked
		addtimer(CALLBACK(src, .proc/traitorcheckloop), 15 MINUTES)
		return

	var/list/possible_autotraitor = list()
	var/playercount = 0
	var/traitorcount = 0

	for(var/mob/living/player in living_list)
		if (player.client && player.mind && player.stat != DEAD)
			playercount++
			if(player.mind.special_role)
				traitorcount++
			else if((player.client && (ROLE_TRAITOR in player.client.prefs.be_role)) && !jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, ROLE_TRAITOR) && !role_available_in_minutes(player, ROLE_TRAITOR) && !isloyal(player))
				if(!possible_autotraitor.len || !possible_autotraitor.Find(player))
					possible_autotraitor += player

	for(var/mob/living/player in possible_autotraitor)
		if(!player.mind || !player.client)
			possible_autotraitor -= player
			continue
		for(var/job in list("Cyborg", "Security Officer", "Security Cadet", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
			if(player.mind.assigned_role == job)
				possible_autotraitor -= player

	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(playercount / 10) + 1
	traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
	if(traitorcount < max_traitors - 1)
		traitor_prob += 50

	if(traitorcount < max_traitors)
		if(prob(traitor_prob))
			message_admins("Making a new Traitor.")
			if(!possible_autotraitor.len)
				message_admins("No potential traitors.  Cancelling new traitor.")
				addtimer(CALLBACK(src, .proc/traitorcheckloop), 15 MINUTES)
				return

			var/mob/living/newtraitor = pick(possible_autotraitor)
			create_and_setup_role(/datum/role/syndicate/traitor, newtraitor)

			to_chat(newtraitor, "<span class='warning'><B>ATTENTION:</B></span> It is time to pay your debt to the Syndicate...")

	addtimer(CALLBACK(src, .proc/traitorcheckloop), 15 MINUTES)

/datum/faction/traitor/auto/OnPostSetup()
	addtimer(CALLBACK(src, .proc/traitorcheckloop), SPAWN_CD)
	return ..()

#undef SPAWN_CD
