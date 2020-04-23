/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/disabilities = 0 //bits
	var/list/mutations = list() //mutation strings
	var/duration = 100 //deciseconds
	/*
		Disabilities
			1st bit - ?
			2nd bit - ?
			3rd bit - ?
			4th bit - ?
			5th bit - ?
			6th bit - ?
	*/

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets)
	cast_with_favor()
	for(var/mob/living/target in targets)
		for(var/x in mutations)
			target.mutations.Add(x)
		target.disabilities |= disabilities
		target.update_mutations()	//update target's mutation overlays
		addtimer(CALLBACK(src, .proc/remove_mutations, target, mutations), duration)

	return

/obj/effect/proc_holder/spell/targeted/genetic/proc/remove_mutations(mob/living/target, list/mutations)
	for(var/x in mutations)
		target.mutations.Remove(x)
	target.disabilities &= ~disabilities
	target.update_mutations()
