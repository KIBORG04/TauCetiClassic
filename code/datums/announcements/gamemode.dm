/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Сетевой Мониторинг"

/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Тревога. Биоугроза"
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/play()
	message = "Подтвержден 5 уровень биологической угрозы на борту [station_name_ru()]. " + \
			"Персонал должен предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	..()

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Тревога. Биоугроза"
	message = "Биологическая опасность достигла критической массы. Потеря станции неминуема."

/datum/announcement/centcomm/blob/biohazard_station_unlock
	name = "Biohazard Level Updated - Lock Down Lifted"
	subtitle = "Biohazard Alert"
	message = "Вспышка биологической угрозы успешно локализована. Карантин снят. Удалите биологически опасные материалы и возвращайтесь к исполнению своих обязанностей."

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Объявление Войны"
	message = "Синдикат объявил о намерении полностью уничтожить станцию с помощью ядерного устройства. И всех, кто попытается их остановить."
/datum/announcement/centcomm/nuclear/war/play(message)
	if(message)
		src.message = message
	..()

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
/datum/announcement/centcomm/vox/arrival/play()
	message = "Внимание, [station_name_ru()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным, этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "ВКН Икар"
/datum/announcement/centcomm/vox/returns/play()
	message = "Ваши гости улетают, [station_name_ru()]. Они движутся слишком быстро, что бы мы могли навестись на них. " + \
			"Похоже, они покидают систему [system_name_ru()] без оглядки."

/* Malfunction */
/datum/announcement/centcomm/malf/declared
	name = "Malf: Declared Victory"
	title = null
	subtitle = null
	message = null
	flags = ANNOUNCE_SOUND
	sound = "malf"

/datum/announcement/centcomm/malf/first
	name = "Malf: Announce №1"
	sound = "malf1"
/datum/announcement/centcomm/malf/first/play()
	message = "Осторожно, [station_name_ru()]. Мы фиксируем необычные показатели в вашей сети. " + \
			"Похоже, кто-то пытается взломать ваши электронные системы. Мы сообщим вам, когда у нас будет больше информации."
	..()

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживать взломщика. Кто-бы это не делал, они находятся на самой станции. " + \
			"Предлагаем проверить все терминалы, управляющие сетью. Будем держать вас в курсе."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "Это крайне не нормально и достаточно тревожно. " + \
			"Взломщик слишком быстр, он обходит все попытки его выследить. Это нечеловеческая скорость..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "Мы отследили взломшик#, это каже@&# ва3) сист7ма ИИ, он# *#@амыает меха#7зм самоун@чт$#енiя. Оста*##ивте )то по*@!)$#&&@@  <СВЯЗЬ ПОТЕРЯНА>"
	sound = "malf4"

/* Cult */
/datum/announcement/station/cult/capture_area
	name = "Anomaly: Bluespace"
	message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: неизвестно."
	sound = "bluspaceanom"
/datum/announcement/station/cult/capture_area/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: [A.name]."
	..()

/* Gang */
/datum/announcement/centcomm/gang/announce_gamemode
	name = "Gang: Announce"
	flags = ANNOUNCE_ALL
/datum/announcement/centcomm/gang/announce_gamemode/play(gang_names)
	message = "Нам поступила информация из достоверного источника, что на [station_name()] зафиксирована деятельность банд:" + \
	" [gang_names]. Управлению станции поручается обеспечить безопасность экипажа.\n" + \
	" В течение часа должна прибыть местная планетарная полиция. Мы им ничего не платили, так что быстро их не ждите.\n\n" + \
	" Шаттл Транспортировки Экипажа сейчас находится на техобслуживании, поэтому вам придётся подождать час с лишним.\n"
	..()

/datum/announcement/centcomm/gang/cops_closely
	name = "Gang: Cops Closely"
/datum/announcement/centcomm/gang/cops_closely/play(gang_names)
	message = "Нам поступила информация, что местная космическая полиция уже приближается к [station_name()]." + \
	" Она прибудет примерно через 5 минут. Напоминаем еще раз, у нас отсутствует юридическое право контролировать" + \
	" напрямую деятельность полиции. Они будут действовать в интересах местного закона и политики."
	..()

/datum/announcement/centcomm/gang/cops_1
	title = "Полицейский Департамент Звёздной Коалиции Тау Киты"
	name = "Gang: Wanted Level 1"
/datum/announcement/centcomm/gang/cops_1/play()
	message = "Здравствуйте, члены экипажа [station_name()]!" + \
	" Мы получили несколько звонков о какой-то там потенциальной деятельности банды насильников на борту вашей станции," + \
	" поэтому мы послали несколько полицейских для оценки ситуации. Ничего экстраординарного, вам не о чем беспокоиться." + \
	" Однако, пока идёт десятиминутная проверка, мы попросили не отсылать вам шаттл.\n\nПриятного дня!"
	..()

/datum/announcement/centcomm/gang/cops_2
	title = "Полицейский Департамент Звёздной Коалиции Тау Киты"
	name = "Gang: Wanted Level 2"
/datum/announcement/centcomm/gang/cops_2/play()
	message = "Экипаж [station_name()]. Мы получили подтверждённые сообщения о насильственной деятельности банд" + \
	" с вашего участка. Мы направили несколько вооружённых офицеров, чтобы помочь поддержать порядок и расследовать дела." + \
	" Не пытайтесь им помешать и выполняйте любые их требования. Мы попросили в течение десятиминут не отсылать вам шаттл.\n\nБезопасного дня!"
	..()

/datum/announcement/centcomm/gang/cops_3
	title = "Полицейский Департамент Звёздной Коалиции Тау Киты"
	name = "Gang: Wanted Level 3"
/datum/announcement/centcomm/gang/cops_3/play()
	message = "Экипаж [station_name()]. Мы получили подтверждённые сообщения о экстремальной деятельности банд" + \
	" с вашей станции, что привело к жертвам среди гражданского персонала. Звёздная Коалиция Тау Киты не потерпит оскорблений к своим гражданским," + \
	" и мы будет действовать в полную силу, чтобы сохранить мир и сократить количество жертв. Мы окружили вашу станцию!" + \
	" Все бандиты должны бросить оружие и мирно сдаться!\n\nБезопасного дня!"
	..()

/datum/announcement/centcomm/gang/cops_4
	title = "Федеральное Бюро Расследований"
	name = "Gang: Wanted Level 4"
/datum/announcement/centcomm/gang/cops_4/play()
	message = "Мы отправили наших лучших агентов на [station_name()] по просьбе Правительства Тау Киты" + \
	" в связи с угрозой террористического характера, направленной против станции НаноТрейзен." + \
	" Все террористы должны НЕМЕДЛЕННО сдаться! Несоблюдение этого требование может привести и ПРИВЕДЁТ к смерти." + \
	" Мы надеемся, что успеем все решить в течение десятиминут, иначе же ждите шаттл и НаноТрейзен само всё решит.\n\nСдавайтесь сейчас или пожалеете!"
	..()

/datum/announcement/centcomm/gang/cops_5
	title = "Национальная Гвардия Звёздной Коалиции Тау Киты"
	name = "Gang: Wanted Level 5"
/datum/announcement/centcomm/gang/cops_5/play()
	message = "Из-за безумного количества жертв среди гражданского персонажа на борту [station_name()]." + \
	" Мы направили Национальную Гвардию, чтобы присечь любую деятельность банд на станции." + \
	" У нас есть БСА, на мушке которая сейчас находится ваша станция и ваш спасательный шаттл.\n\nЗря вы убили столько людей."
	..()

/datum/announcement/centcomm/gang/change_wanted_level
	title = "Система Обнаружения Кораблей Станции"
	name = "Gang: Change Wanted Level"
/datum/announcement/centcomm/gang/change_wanted_level/play(_message)
	message = _message
	..()
