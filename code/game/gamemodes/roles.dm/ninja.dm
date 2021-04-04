/datum/role/ninja
	name = NINJA
	id = NINJA
	required_pref = NINJA
	special_role = NINJA
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_NINJA
	antag_hud_name = "hudninja"

	restricted_jobs = list("Cyborg", "AI")
	logo_state = "ninja-logo"

/datum/role/ninja/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/ninja = antag.current
	ninja.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	ninja.dna.ready_dna(ninja)
	ninja.equip_space_ninja(TRUE)
	ninja.internal = ninja.s_store
	ninja.internals.icon_state = "internal1"
	if(ninja.wear_suit && istype(ninja.wear_suit,/obj/item/clothing/suit/space/space_ninja))
		var/obj/item/clothing/suit/space/space_ninja/S = ninja.wear_suit
		S.randomize_param()

/datum/role/ninja/proc/get_other_ninja()
	for(var/datum/role/R in faction.members)
		if(R != src)
			return R

/datum/role/ninja/forgeObjectives()
	var/datum/role/second_ninja = get_other_ninja()
	if(!antag.protector_role && !second_ninja)
		var/objective_list = list(1,2,3,4)
		for(var/i = rand(2,4), i > 0, i--)
			switch(pick(objective_list))
				if(1)
					AppendObjective(/datum/objective/assassinate)
					objective_list -= 1
				if(2)
					AppendObjective(/datum/objective/steal)
				if(3)
					AppendObjective(/datum/objective/download)
				if(4)
					AppendObjective(/datum/objective/harm)
	else
		if(!second_ninja.antag.protector_role)
			for(var/datum/objective/objective_p in second_ninja.objectives.GetObjectives())
				if(istype(objective_p, /datum/objective/assassinate))
					if(objective_p.target.current == antag.current)
						continue
					if(objective_p.target.current == second_ninja.antag.current)
						continue
					var/datum/objective/protect/ninja_objective = AppendObjective(/datum/objective/protect)

					ninja_objective.target = objective_p.target
					ninja_objective.explanation_text = "Protect [objective_p.target.current.real_name], the [objective_p.target.assigned_role]."

				if(istype(objective_p, /datum/objective/steal))
					var/datum/objective/steal/ninja_objective = AppendObjective(/datum/objective/steal)

					ninja_objective.target = objective_p.target
					ninja_objective.steal_target = objective_p.target
					ninja_objective.explanation_text = objective_p.explanation_text

				if(istype(objective_p, /datum/objective/download))
					var/datum/objective/download/ninja_objective = AppendObjective(/datum/objective/download)
					ninja_objective.target_amount = objective_p.target_amount
					ninja_objective.explanation_text = objective_p.explanation_text

				if(istype(objective_p, /datum/objective/harm))
					if(objective_p.target.current == antag.current)
						continue
					if(objective_p.target.current == second_ninja.antag.current)
						continue
					var/datum/objective/protect/ninja_objective = AppendObjective(/datum/objective/protect)
					ninja_objective.target = objective_p.target
					ninja_objective.explanation_text = objective_p.explanation_text

			var/datum/objective/assassinate/ninja_objective = AppendObjective(/datum/objective/assassinate)
			ninja_objective.target = second_ninja.antag
			ninja_objective.explanation_text = "Assassinate [second_ninja.antag.current.real_name], the [second_ninja.antag.special_role]."

	AppendObjective(/datum/objective/survive)

/datum/role/ninja/Greet(greeting, custom)
	. = ..()
	var/directive = generate_ninja_directive("heel") //Only hired by antags, not NT
	to_chat(antag.current, "<span class = 'info'><B>You are <font color='red'>Ninja</font>!</B></span>")
	to_chat(antag.current, "You are an elite mercenary assassin of the Spider Clan, [antag.current.real_name]. You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor")
	to_chat(antag.current, "Your current directive is: <span class = 'red'><B>[directive]</B></span>")
	to_chat(antag.current, "<span class = 'info'>Try your best to adhere to this.</span>")
	antag.store_memory("<B>Directive:</B> <span class='red'>[directive]</span><br>")
