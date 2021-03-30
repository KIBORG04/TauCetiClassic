//________________________________________________

#define WAIT_TIME_PHASE1 60 SECONDS
#define WAIT_TIME_PHASE2 200 SECONDS

#define PLAYER_PER_BLOB_CORE 30

#define STATION_TAKEOVER 1
#define STATION_WAS_NUKED 2
#define BLOB_IS_DED 3

#define CREW_VICTORY 0
#define AI_VICTORY 1 // Station was nuked.
#define BLOB_VICTORY 2

/datum/faction/blob_conglomerate
	name = BLOBCONGLOMERATE
	ID = BLOBCONGLOMERATE
	logo_state = "blob-logo"

	initroletype = /datum/role/blob_overmind
	initial_role = BLOBOVERMIND

	roletype = /datum/role/blob_overmind/cerebrate
	late_role = BLOBCEREBRATE

	var/datum/station_state/start

	var/list/pre_escapees = list()
	var/declared = FALSE
	var/win = FALSE
	var/blobwincount = 0
	var/prelude_announcement
	var/outbreak_announcement

/datum/faction/blob_conglomerate/can_setup(num_players)
	max_roles = max(round(num_players/PLAYER_PER_BLOB_CORE, 1), 1)
	return TRUE

// -- Victory procs --
/datum/faction/blob_conglomerate/check_win()
	if(!declared) //No blobs have been spawned yet
		return FALSE
	var/ded = TRUE
	for (var/datum/role/R in members)
		if (R.antag && R.antag.current && !(R.antag.current.is_dead()))
			ded = FALSE
	if(ded)
		stage(FACTION_DEFEATED)

/datum/faction/blob_conglomerate/HandleNewMind(datum/mind/M)
	if(..())
		OnPostSetup() //We didn't finish setting up!

/datum/faction/blob_conglomerate/process()
	. = ..()
	if(!blobwincount)
		return .
	if(prelude_announcement && world.time >= prelude_announcement && detect_overminds())
		prelude_announcement = 0
		stage(FACTION_DORMANT)
	if(outbreak_announcement && world.time >= outbreak_announcement && detect_overminds()) //Must be alive to advance.
		outbreak_announcement = 0
		stage(FACTION_ACTIVE)
	if(declared && 0.66*blobwincount <= blobs.len && stage<FACTION_ENDGAME) // Blob almost won !
		stage(FACTION_ENDGAME)

/datum/faction/blob_conglomerate/OnPostSetup()
	CountFloors()
	forgeObjectives()
	AnnounceObjectives()
	start = new()
	start.count()
	prelude_announcement = world.time + rand(WAIT_TIME_PHASE1,2*WAIT_TIME_PHASE1)
	outbreak_announcement = world.time + rand(WAIT_TIME_PHASE2,2*WAIT_TIME_PHASE2)
	return ..()

/datum/faction/blob_conglomerate/proc/CountFloors()
	var/floor_count = 0
	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, pick(SSmapping.levels_by_trait(ZTRAIT_STATION)))
			if(tile && istype(tile, /turf/simulated/floor) && !isspace(tile.loc) && !istype(tile.loc, /area/station/bridge/nuke_storage) && !istype(tile.loc, /area/station/security/prison))
				floor_count++
	blobwincount = round(floor_count *  0.25) // Must take over a quarter of the station.
	blobwincount += rand(-50,50)


/datum/faction/blob_conglomerate/forgeObjectives()
	AppendObjective(/datum/objective/blob_takeover)

// -- Fluff & warnings --

/datum/faction/blob_conglomerate/AdminPanelEntry()
	. = ..()
	. += "<br/>Station takeover: [blobs.len]/[blobwincount]."

/datum/faction/blob_conglomerate/stage(stage)
	switch(stage)
		if(FACTION_DORMANT)
			if (!declared)
				declared = TRUE
				var/datum/announcement/centcomm/blob/outbreak5/announcement = new
				announcement.play()
				return
		if(FACTION_ACTIVE)
			for(var/mob/M in player_list)
				var/T = M.loc
				if(istype(T, /turf/space) || istype(T, /turf) && !is_station_level(M.z))
					pre_escapees += M.real_name
			send_intercept(FACTION_ACTIVE)
			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "The station is under quarantine. Do not permit anyone to leave so long as blob overminds are present. Disregard all other laws if necessary to preserve quarantine."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")
			SSshuttle.always_fake_recall = TRUE //Quarantine
		if(FACTION_ENDGAME)
			var/datum/announcement/centcomm/blob/critical/announcement = new
			announcement.play()
			for(var/mob/camera/blob/B in player_list)
				to_chat(B, "<span class='blob'>The beings intend to eliminate you with a final suicidal attack, you must stop them quickly or consume the station before this occurs!</span>")
			send_intercept(FACTION_ENDGAME)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in machines)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						nukecode = bomb.r_code
			for(var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "Directive 7-12 has been authorized. Allow no sentient being to escape the purge. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")
			..() //Set thematic, set alert
		if (FACTION_DEFEATED) //Cleanup time
			var/datum/announcement/centcomm/blob/biohazard_station_unlock/announcement = new
			announcement.play()

			send_intercept(FACTION_DEFEATED)
			SSshuttle.always_fake_recall = FALSE
			declared = FALSE
			world << sound('sound/misc/notice1.ogg')
			for(var/mob/living/silicon/ai/aiPlayer in player_list)
				aiPlayer.set_zeroth_law("")
				to_chat(aiPlayer, "Laws Updated. Lockdown has been lifted.")

/datum/faction/blob_conglomerate/proc/send_intercept(report = FACTION_ACTIVE)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(FACTION_ACTIVE)
			interceptname = "Biohazard Alert"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.
Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.
Nanotrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.
Orders for all [station_name()] personnel follows:
<ol>
	<li>Do not leave the quarantine area.</li>
	<li>Locate any outbreaks of the organism on the station.</li>
	<li>If found, use any neccesary means to contain the organism.</li>
	<li>Avoid damage to the capital infrastructure of the station.</li>
</ol>
Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.
Message ends."}

		if(FACTION_ENDGAME)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in machines)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Directive 7-12 has been issued for [station_name()].
The biohazard has grown out of control and will soon reach critical mass.
Your orders are as follows:
<ol>
	<li>Secure the Nuclear Authentication Disk.</li>
	<li>Detonate the Nuke located in the Station's Vault.</li>
</ol>
<b>Nuclear Authentication Code:</b> [nukecode]
Message ends."}

		if(FACTION_DEFEATED)
			interceptname = "Directive 7-12 lifted"
			intercepttext = {"<Font size = 3><B>Nanotrasen Update</B>: Biohazard contained.</FONT><HR>
Directive 7-12 has been lifted for [station_name()].
The biohazard has been contained. Please resume normal station activities.
Message ends."}
	for(var/obj/machinery/computer/communications/comm in communications_list)
		comm.messagetitle.Add(interceptname)
		comm.messagetext.Add(intercepttext)
		if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
			intercept.update_icon()


// -- Scoreboard --
/datum/faction/blob_conglomerate/GetScoreboard()
	var/dat = ..()
	dat += "<br/>"
	switch (win)
		if (STATION_TAKEOVER)
			dat += "<b>Blob victory!</b>"
		if (STATION_WAS_NUKED)
			dat += "<b>Crew minor victory!</b>"
		if (BLOB_IS_DED)
			dat += "<b>Crew victory!</b>"
	dat += "<br />"
	var/datum/station_state/end = new
	end.count()
	dat += "<b>Total blobs: [blobs.len]</b><br/>"
	dat += "<b>Station Integrity: [round(end.score(start)*100)]%</b><br/>"
	dat += "<br/>"
	dat += "<b>Quarantaine status:</b><br/>"
	var/list/result = check_quarantaine()
	dat += "Dead humans: <b>[result["numDead"]]</b><br/>"
	dat += "Alive humans still on board: <b>[result["numAlive"]]</b><br/>"
	dat += "Humans in space: <b>[result["numSpace"]]</b><br/>"
	dat += "Humans off-station: <b>[result["numOffStation"]]</b><br/>"
	dat += "Pre-escapes: <b>[pre_escapees.len]</b><br/>"
	if (detect_overminds() && (result["numOffStation"] + result["numSpace"]))
		dat += "<span class='danger'>The AI has failed to enforce the quarantine.</span>"
	else
		dat += "<span class='good'>The AI has managed to enforce the quarantine.</span><BR>"
	return dat

/datum/faction/blob_conglomerate/proc/detect_overminds()
	for(var/datum/role/R in members)
		if(R.antag.current)
			return TRUE
	return FALSE

/datum/faction/blob_conglomerate/proc/check_quarantaine()
	var/list/result = list()
	result["numDead"] = 0
	result["numSpace"] = 0
	result["numAlive"] = 0
	result["numOffStation"] = 0
	for(var/mob/living/carbon/human/M in player_list)
		if (M.is_dead())
			result["numDead"]++
		else if(M.real_name in pre_escapees)
			continue
		else
			var/T = M.loc
			if (istype(T, /turf/space))
				result["numSpace"]++
			else if(istype(T, /turf))
				if (M.z!=1)
					result["numOffStation"]++
				else
					result["numAlive"]++
	return result

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0
	var/num_territories = 1//Number of total valid territories for gang mode

/datum/station_state/proc/count(count_territories)
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/T in block(locate(1, 1, Z), locate(world.maxx, world.maxy, Z)))
			if(istype(T,/turf/simulated/floor))
				var/turf/simulated/floor/F = T
				if(!F.burnt)
					floor += 12
				else
					floor += 1

			if(istype(T, /turf/simulated/wall))
				if(T.intact)
					wall += 2
				else
					wall += 1

			if(istype(T, /turf/simulated/wall/r_wall))
				if(T.intact)
					r_wall += 2
				else
					r_wall += 1

			for(var/obj/O in T.contents)
				if(istype(O, /obj/structure/window))
					window += 1
				else if(istype(O, /obj/structure/grille))
					var/obj/structure/grille/G = O
					if(!G.destroyed)
						grille += 1
				else if(istype(O, /obj/machinery/door))
					door += 1
				else if(istype(O, /obj/machinery))
					mach += 1

	if(count_territories)
		var/list/valid_territories = list()
		for(var/area/A in all_areas) //First, collect all area types on the station zlevel
			if(is_station_level(A.z))
				if(!(A.type in valid_territories) && A.valid_territory)
					valid_territories |= A.type
		if(valid_territories.len)
			num_territories = valid_territories.len //Add them all up to make the total number of area types
		else
			to_chat(world, "ERROR: NO VALID TERRITORIES")

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)	return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall / max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)

#undef WAIT_TIME_PHASE1
#undef WAIT_TIME_PHASE2
#undef PLAYER_PER_BLOB_CORE
#undef STATION_TAKEOVER
#undef STATION_WAS_NUKED
#undef BLOB_IS_DED
#undef CREW_VICTORY
#undef AI_VICTORY
#undef BLOB_VICTORY
