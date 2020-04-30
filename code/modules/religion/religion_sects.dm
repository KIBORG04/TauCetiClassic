/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion_sect
	var/name = "Basic sect"
/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
/// Opening message when someone gets converted
	var/convert_opener
/// Does this require something before being available as an option?
	var/starter = TRUE
/// Allow choose aspect in sect
	var/allow_aspect = FALSE
/// Fast choose aspects
	var/list/datum/aspect/aspect_preset

/datum/religion_sect/New()
	on_select()

/// Activates once selected
/datum/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")

/datum/religion_sect/puritanism
	name = "The Puritan of "
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"
	aspect_preset = list(/datum/aspect/salutis, /datum/aspect/lux, /datum/aspect/spiritus)

/datum/religion_sect/technophile
	name = "The Technomancers of "
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte."
	aspect_preset = list(/datum/aspect/technology, /datum/aspect/progressus, /datum/aspect/metallum)

/datum/religion_sect/custom
	name = "Custom "
	desc = "Follow the orders of your god."
	convert_opener = "I am the first to enter here..."
	allow_aspect = TRUE
