/datum/role/alien
	name = XENOMORPH
	id = XENOMORPH
	required_pref = ROLE_ALIEN
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_ALIEN
	antag_hud_name = "hudalien"

	logo_state = "xeno-logo"

/datum/role/alien/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Вы - ксеноморф. Ваша текущая форма - грудолом.
Сейчас вы очень слабы и вас легко убить.
Прячьтесь под предметами и передвигайтесь по вентиляции, что бы сохранить свою жизнь.
Ваша главная задача - вырасти во взрослого ксеноморфа. Прогресс роста указан во вкладке Status.
Когда прогресс роста дойдет до конца, вы сможете эволюционировать в оду из трех взрослых форм.
Договоритесь со своими сестрами, кто и в какую форму будет эволюционировать.
Для общения внутри улья поставьте :ф перед сообщением.
Кто-то обязательно должен стать трутнем, это единственная форма, способная вырасти в королеву.
------------------</b></span>"})

