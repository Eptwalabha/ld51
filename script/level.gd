extends Node

enum LEVEL_NAME {
	INTRO,
	INTRO2,
	INTRO3,
	BOUNCE,
	DONT_TURN_LIGHT,
	RANDOM_BOUNCE,
	FAKE_1,
	NO_CAP,
	NEED_POWER,
	SHRINK_BOUNCE,
	TINY,
	FALLING_OBJECT,
	FAKE_2,
	NO_COUNTER,
	LIGHT_TOO_SOON,
	TP_RANDOM,
	FAKE_THE_RETURN,
	FALL,
	SHRINK,
	TP_RANDOM_TINY,
	IN_THE_DARK,
	NEED_POWER_MAZE,
	RANDOM_SHRINK_BOUNCE,
	IDLE
}

const levels: Array[LEVEL_NAME] = [

	LEVEL_NAME.TP_RANDOM_TINY,

	LEVEL_NAME.INTRO,
	LEVEL_NAME.INTRO2,
	LEVEL_NAME.INTRO3,
	LEVEL_NAME.BOUNCE,
	LEVEL_NAME.DONT_TURN_LIGHT,
	LEVEL_NAME.RANDOM_BOUNCE,
	LEVEL_NAME.FAKE_1,
	LEVEL_NAME.NO_CAP,
	LEVEL_NAME.NEED_POWER,
	LEVEL_NAME.SHRINK_BOUNCE,
	LEVEL_NAME.TINY,
	LEVEL_NAME.FALLING_OBJECT,
	LEVEL_NAME.FAKE_2,
	LEVEL_NAME.IDLE,
	LEVEL_NAME.NO_COUNTER,
	LEVEL_NAME.LIGHT_TOO_SOON,
	LEVEL_NAME.TP_RANDOM,
	LEVEL_NAME.FAKE_THE_RETURN,
	LEVEL_NAME.FALL,
	LEVEL_NAME.SHRINK,
	LEVEL_NAME.TP_RANDOM_TINY,
	LEVEL_NAME.IN_THE_DARK,
	LEVEL_NAME.NEED_POWER_MAZE,
	LEVEL_NAME.RANDOM_SHRINK_BOUNCE,
]

func has_next_level(level_index: int) -> bool:
	return level_index >= levels.size()

func get_dialog(level: LEVEL_NAME) -> String:
	match level:
		LEVEL_NAME.INTRO: return "intro-01"
		LEVEL_NAME.INTRO2: return "intro-02"
		LEVEL_NAME.INTRO3: return "intro-03"
		LEVEL_NAME.FALLING_OBJECT: return "falling-object"
		LEVEL_NAME.TP_RANDOM: return "td-random"
		LEVEL_NAME.RANDOM_SHRINK_BOUNCE: return "random-shrink-bounce"
		LEVEL_NAME.RANDOM_BOUNCE: return "random-bounce"
		LEVEL_NAME.BOUNCE: return "bounce"
		LEVEL_NAME.SHRINK_BOUNCE: return "shrink-bounce"
		LEVEL_NAME.SHRINK: return "shrink"
		LEVEL_NAME.FAKE_1: return "fake-01"
		LEVEL_NAME.FAKE_2: return "fake-02"
		LEVEL_NAME.FAKE_THE_RETURN: return "fake-03"
		LEVEL_NAME.NEED_POWER_MAZE: return "power-maze"
		LEVEL_NAME.TINY: return "tiny"
		LEVEL_NAME.TP_RANDOM_TINY: return "tp-random-tiny"
		LEVEL_NAME.NO_CAP: return "no-cap"
		LEVEL_NAME.NEED_POWER: return "need-power"
		LEVEL_NAME.FALL: return "fall"
		LEVEL_NAME.NO_COUNTER: return "no-counter"
		LEVEL_NAME.DONT_TURN_LIGHT: return "no-light"
		LEVEL_NAME.LIGHT_TOO_SOON: return "too-soon"
		LEVEL_NAME.IN_THE_DARK: return "pitch-black"
		LEVEL_NAME.IDLE: return "idle"
		_: return ""

func get_game_over_dialog(level: LEVEL_NAME) -> String:
	match level:
		LEVEL_NAME.INTRO, LEVEL_NAME.INTRO2, LEVEL_NAME.INTRO2:
			return "game-over-intro"
		LEVEL_NAME.LIGHT_TOO_SOON:
			return "game-over-too-soon"
		LEVEL_NAME.NO_CAP:
			return "game-over-no-cap"
		LEVEL_NAME.TINY, LEVEL_NAME.TP_RANDOM_TINY:
			return "game-over-tiny"
		LEVEL_NAME.IDLE:
			return "game-over-idle"
		_:
			return "game-over"
