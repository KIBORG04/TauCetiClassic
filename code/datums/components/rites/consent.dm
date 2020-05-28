/*
 This component used in chaplain rite for ask question at victim on altar.
*/
/datum/component/rite_consent
	var/consent = FALSE
	var/def_consent = FALSE

/datum/component/rite_consent/Initialize()
	RegisterSignal(parent, list(COMSIG_RITE_REQUIRED_CHECK), .proc/check_victim)
	RegisterSignal(parent, list(COMSIG_RITE_ON_CHOSEN), .proc/victim_ask)

// Checks for a victim
/datum/component/rite_consent/proc/check_victim(datum/source, mob/user, atom/movable/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return COMPONENT_NO_CONSENT
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return COMPONENT_NO_CONSENT
	if(!consent)
		var/mob/victim = AOG.buckled_mob
		to_chat(user, "<span class='warning'>[victim] does not want to give themselves into this ritual!.</span>")
		return COMPONENT_NO_CONSENT
	// revert consent to it's default
	consent = def_consent
	return FALSE

// Send ask to victim
/datum/component/rite_consent/proc/victim_ask(datum/source, mob/user, atom/movable/AOG, msg)
	var/mob/victim = AOG.buckled_mob
	if(!victim.IsAdvancedToolUser())
		consent = TRUE
	else 
		if(alert(victim, msg, "Rite", "Yes", "No") == "Yes")
			consent = TRUE
