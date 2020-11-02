
/proc/iscultist(mob/living/M)
	return M && global.cult_religion && (M in global.cult_religion.members)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return FALSE
	if(ishuman(mind.current))
		if((mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(mind.current.get_species() == GOLEM)
			return FALSE
	if(ismindshielded(mind.current) || isloyal(mind.current))
		return FALSE
	return TRUE


/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	role_type = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	protected_jobs = list()
	// TEST FOR DEBUGGING OF THE GAME OF CULT OF BLOOD
	required_players = 0
	required_players_secret = 0
	// REMEMBER IT!!!!
	required_enemies = 0
	recommended_enemies = 0

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	votable = 0

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 20

	restricted_species_flags = list(NO_BLOOD)

	var/datum/mind/sacrifice_target = null
	var/list/datum/mind/started_cultists = list()

	var/finished = 0

	var/list/startwords = list("blood","join","self","hell")

	var/list/objectives = list()
	var/list/sacrificed = list()

	var/eldergod = 1 //for the summon god objective
	var/eldertry = 0

	var/const/acolytes_needed = 5 //for the survive objective
	var/acolytes_survived = 0

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(!config.objectives_disabled)
		if(prob(50))
			objectives += "survive"
			objectives += "sacrifice"
		else
			objectives += "eldergod"
			objectives += "sacrifice"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		if(player.assigned_role in restricted_jobs)	//Removing heads and such from the list
			antag_candidates -= player

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		started_cultists += cultist

	return (started_cultists.len >= required_enemies)


/datum/game_mode/cult/post_setup()
	create_religion(/datum/religion/cult)
	modePlayer += started_cultists
	if("sacrifice" in objectives)
		var/list/possible_targets = get_unconvertables()
		listclearnulls(possible_targets)

		if(!possible_targets.len)
			for(var/mob/living/carbon/human/player in player_list)
				if(player.mind && !(player.mind in started_cultists))
					possible_targets += player.mind

		listclearnulls(possible_targets)

		if(length(possible_targets))
			sacrifice_target = pick(possible_targets)

	for(var/datum/mind/cult_mind in started_cultists)
		global.cult_religion.add_member(cult_mind.current, HOLY_ROLE_HIGHPRIEST)
		equip_cultist(cult_mind.current)
		to_chat(cult_mind.current, "<span class = 'info'><b>You are a member of the <font color='red'>cult</font>!</b></span>")

		if(!config.objectives_disabled)
			memoize_cult_objectives(cult_mind)
		else
			to_chat(cult_mind.current, "<span class ='blue'>Within the rules,</span> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
		cult_mind.special_role = "Cultist"
		add_antag_hud(antag_hud_type, antag_hud_name, cult_mind.current)


	return ..()

/datum/game_mode/cult/proc/memoize_cult_objectives(datum/mind/cult_mind)
	for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
			if("sacrifice")
				if(sacrifice_target)
					explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell blood join) and three acolytes to do so."
				else
					explanation = "Free objective."
			if("eldergod")
				explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
		to_chat(cult_mind.current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"
	to_chat(cult_mind.current, "The convert rune is join blood self")
	cult_mind.memory += "The convert rune is join blood self<BR>"

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)

	global.cult_religion.give_tome(mob)

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if(!istype(cult_mind))
		return FALSE
	if(is_convertable_to_cult(cult_mind))
		global.cult_religion.add_member(cult_mind.current, HOLY_ROLE_HIGHPRIEST)
		cult_mind.current.Paralyse(5)
		cult += cult_mind
		add_antag_hud(ANTAG_HUD_CULT, "hudcultist", cult_mind.current)

		return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	if (!config.objectives_disabled)
		memoize_cult_objectives(cult_mind)

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		remove_antag_hud(ANTAG_HUD_CULT, cult_mind.current)
		cult_mind.current.Paralyse(5)
		to_chat(cult_mind.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</span></FONT>")
		cult_mind.memory = ""
		if(show_message)
			cult_mind.current.visible_message("<span class='danger'><FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</span></FONT>")

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("sacrifice"))
		if(sacrifice_target && !sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure

/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in global.cult_religion.members)
		if (cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if ( is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1

/datum/game_mode/cult/declare_completion()
	if(config.objectives_disabled)
		return 1
	completion_text += "<h3>Cult mode resume:</h3>"
	if(!check_cult_victory())
		mode_result = "win - cult win"
		feedback_set_details("round_end_result",mode_result)
		feedback_set("round_end_result",acolytes_survived)
		completion_text += "<span class='color: red; font-weight: bold;'>The cult <span style='color: green'>wins</span>! It has succeeded in serving its dark masters!</span><br>"
		score["roleswon"]++
	else
		mode_result = "loss - staff stopped the cult"
		feedback_set_details("round_end_result",mode_result)
		feedback_set("round_end_result",acolytes_survived)
		completion_text += "<span class='color: red; font-weight: bold;'>The staff managed to stop the cult!</span><br>"

	var/text = "<b>Cultists escaped:</b> [acolytes_survived]"
	if(!config.objectives_disabled)
		if(objectives.len)
			text += "<br><b>The cultists' objectives were:</b>"
			for(var/obj_count in 1 to objectives.len)
				var/explanation
				switch(objectives[obj_count])
					if("survive")
						if(!check_survive())
							explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
						else
							explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <span style='color: red; font-weight: bold;'>Fail.</span>"
							feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
					if("sacrifice")
						if(sacrifice_target)
							if(sacrifice_target in sacrificed)
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: green; font-weight: bold;'>Success!</span>"
								feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
							else if(sacrifice_target && sacrifice_target.current)
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Fail.</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL")
							else
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Fail (Gibbed).</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
						else
							explanation = "Free objective. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_free_objective|SUCCESS")
					if("eldergod")
						if(!eldergod)
							explanation = "Summon Nar-Sie. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_narsie|SUCCESS")
						else
							explanation = "Summon Nar-Sie. <span style='color: red; font-weight: bold;'>Fail.</span>"
						feedback_add_details("cult_objective","cult_narsie|FAIL")
				text += "<br><b>Objective #[obj_count]</b>: [explanation]"

	completion_text += text
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_cult()
	var/text = ""
	if(global.cult_religion.members.len || (SSticker && istype(SSticker.mode, /datum/game_mode/cult)) )
		text += printlogo("cult", "cultists")
		for(var/datum/mind/cultist in global.cult_religion.members)
			text += printplayerwithicon(cultist)

	if(text)
		antagonists_completion += list(list("mode" = "cult", "html" = text))
		text = "<div class='Section'>[text]</div>"

	return text
