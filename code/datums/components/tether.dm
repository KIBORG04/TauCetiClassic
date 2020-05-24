/obj/item/rope
	icon = 'icons/effects/beam.dmi'
	icon_state = "n_beam"
	var/lenght = 0
	var/used = FALSE
	var/atom/bounded
	var/obj/item/rope/next
	var/obj/item/rope/prev

	var/atom/holding

/obj/item/rope/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /turf))
		return
	if(!used)
		used = TRUE
		bounded = target
		AddComponent(/datum/component/tethered, 5, bounded)
		user.AddComponent(/datum/component/bounded, bounded, 0, lenght)

/obj/item/rope/pickup(mob/user)
	holding = user
	var/obj/item/rope/last = src
	if(lenght == 0)
		while(last.prev)
			last = last.prev
			last.used = used
			last.bounded = bounded
			lenght++
	if(used)
		user.AddComponent(/datum/component/bounded, bounded, 0, lenght)

/obj/item/rope/dropped(mob/user)
	holding = null
	if(used)
		qdel(user.GetComponent(/datum/component/bounded))

/obj/item/rope/proc/recursive_pull()
	if(holding && !in_range(src, holding))
		step_to(src, holding)
		if(!in_range(src, holding))
			prev.recursive_pull()
			step_to(src, holding)
	if(!in_range(src, prev))
		step_to(prev, src)
		if(!in_range(src, prev))
			prev.recursive_pull()
			step_to(src, prev)

/datum/component/tethered
	var/atom/tethered_to

	var/obj/item/rope/start
	var/obj/item/rope/finish

/datum/component/tethered/Initialize(rope_length, atom/tethered_obj)
	var/atom/movable/AM = parent
	tethered_to = tethered_obj
	start = new(tethered_to.loc)
	finish = AM

	start.next = finish
	finish.prev = start
	
	var/obj/item/rope/prev = start
	var/obj/item/rope/new_rope
	var/atom/path = get_step(start, finish.dir)
	for(var/i in 3 to rope_length)
		new_rope = new(path)
		prev.next = new_rope
		finish.prev = new_rope
		new_rope.prev = prev
		new_rope.next = finish
		prev = new_rope
		path = get_step(new_rope, 2)
		//path = get_step(new_rope, finish.dir)

	if(istype(AM.loc, /mob))
		RegisterSignal(AM.loc, list(COMSIG_MOVABLE_MOVED), .proc/update_tether)
	if(istype(tethered_to, /atom/movable))
		RegisterSignal(tethered_to, list(COMSIG_MOVABLE_MOVED), .proc/update_tethered)

/datum/component/tethered/proc/update_tethered()
	to_chat(world, "1 Chi kak?")
	start.recursive_pull()

/datum/component/tethered/proc/update_tether()
	to_chat(world, "2 Chi kak?")
	finish.recursive_pull()
