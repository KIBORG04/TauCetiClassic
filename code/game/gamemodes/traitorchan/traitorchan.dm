/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	role_type = ROLE_CHANGELING
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	minimum_player_count = 3
	minimum_players_bundles = 25
	required_enemies = 2
	recommended_enemies = 3

	votable = 0

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<B>The current game mode is - Traitor+Changeling!</B>")
	to_chat(world, "<B>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</B>")


/datum/game_mode/traitor/changeling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		if(player.assigned_role in restricted_jobs)	//Removing robots from the list
			antag_candidates -= player

	if(antag_candidates.len>0)
		var/datum/mind/changeling = pick(antag_candidates)
		//possible_changelings-=changeling
		changelings += changeling

		return ..()
	else
		return 0

