/**
  * Approval system of god and mood of god
  * This framework gives different effects depending on the settings
*/

/datum/god_approval
	// Name of god
	var/name
	// Mood of god
	var/mood = 0.0
	// Increase or decrease passive mood
	var/passive_mood_change = 0.0
	// Max and min mood
	var/mood_scope = 10
	// Religion to which god belongs
	var/datum/religion/god_religion
	// All possibles effects to members of religion
	var/list/effects
	// Time when need next update mood
	var/mood_update

/datum/god_approval/New()
	START_PROCESSING(SSreligion, src)

/datum/god_approval/proc/adjust_mood(value)
	mood = clamp(mood + value, -mood_scope, mood_scope)

/datum/god_approval/process()
	if(mood_update < world.time)
		adjust_mood(passive_mood_change)
		mood_update = world.time + 10 MINUTES

