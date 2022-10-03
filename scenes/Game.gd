extends Node2D

var remaining: float = 0.0
var game_started: bool = false
var game_over: bool = false
var press_count: int = 0
var level_end: bool = true
var b_scale: Vector2 = Vector2(.5, .5)
var bouncing_direction: Vector2 = Vector2.UP
var moving_speed : float = 200.0

onready var count_down : Label = $"%CountDown"
onready var dialog : Label = $"%Dialog"
onready var buzzer : Buzzer = $"%Buzzer"
onready var sticky : StickyNote = $"%Sticky"
onready var fade : Fade = $"%Fade"
onready var eptwalabha : Label = $"%Eptwalabha"
onready var powerArea : PowerArea = $BG/PowerArea
onready var timer : Timer = $Timer

export(Curve) var shrink_curve
export(float) var duration : float = 10.0
export(float) var extra_time : float = 1.0

enum LEVEL {
	NOTHING,
	INTRO,
	FAKE_1,
	FAKE_2,
	FAKE_THE_RETURN,
	INTRO2,
	INTRO3,
	BOUNCE,
#	FALLING_OBJECT,

	TP_RANDOM,
	RANDOM_SHRINK_BOUNCE,
	RANDOM_BOUNCE,
	SHRINK_BOUNCE,
	SHRINK,
	NEED_POWER_MAZE,
	TINY,
	TP_RANDOM_TINY,
	NO_CAP,
	NEED_POWER,
	FALL,
	NO_COUNTER,
	DONT_TURN_LIGHT,
	LIGHT_TOO_SOON,
	IN_THE_DARK,
	VICTORY
}

func _ready() -> void:
	randomize()
	count_down.hide()
	buzzer.turn_light(true, true)
	reset_all_items()
	fade.fade_in()

func _process(delta: float) -> void:
	if !game_started or game_over or level_end:
		return

	if remaining <= 0:
		turn_on_buzzer_light()
		if abs(remaining) > extra_time :
			remaining = extra_time
			buzzer.turn_light(false)
			trigger_game_over()

	update_buzzer(delta)
	update_count_down()
	remaining -= delta
	Stats.total_time += delta

func update_buzzer(delta: float) -> void:
	match press_count:
		LEVEL.SHRINK:
			update_buzzer_scale()
		LEVEL.BOUNCE, LEVEL.RANDOM_BOUNCE:
			bounce_buzzer(delta)
		LEVEL.SHRINK_BOUNCE, LEVEL.RANDOM_SHRINK_BOUNCE:
			update_buzzer_scale()
			bounce_buzzer(delta)

func update_buzzer_scale() -> void:
	var x = min(1.0, (duration - remaining) / duration)
	buzzer.scale = b_scale * shrink_curve.interpolate(x)

func bounce_buzzer(delta: float) -> void:
	var next_position : Vector2 = buzzer.global_position + bouncing_direction * delta * moving_speed
	if next_position.x < 150 and bouncing_direction.x < 0 \
		or next_position.x > 650 and bouncing_direction.x > 0.0:
		bouncing_direction.x *= -1
	if next_position.y < 200 and bouncing_direction.y < 0 \
		or next_position.y > 700 and bouncing_direction.y > 0.0:
		bouncing_direction.y *= -1
	buzzer.global_position = next_position

func start_random_timer() -> void:
	timer.start(randf() * 1.5 + .5)

func update_count_down() -> void:
	if remaining <= 0.0 or game_over:
		count_down.text = "0.00"
	else:
		var second : int = int(floor(abs(remaining)))
		var milli : int = int(100.0 * fmod(abs(remaining), 1.0))
		count_down.text = "%s.%s" % [second, milli]

func start_game() -> void:
	eptwalabha.visible = false
	game_started = true
	next_level()

func turn_on_buzzer_light() -> void:
	match press_count:
		LEVEL.DONT_TURN_LIGHT:
			pass
		_:
			buzzer.turn_light()

func move_buzzer_at_random() -> void:
	buzzer.global_position = random_position()

func random_position() -> Vector2:
	return Vector2(100, 200) + Vector2(600 * randf(), 400 * randf())

func random_direction() -> Vector2:
	return (Vector2(1 - randf() * 2, 1 - randf() * 2)).normalized()

func reset_all_items() -> void:
	timer.stop()
	for item in $BG.get_children():
		item.reset()

func next_level() -> void:
	buzzer.reset()
	buzzer.rotation = 0
	var new_buzzer_position: = Vector2(400, 600)
	buzzer.turn_light(false)
	buzzer.scale = b_scale
	count_down.visible = true
	powerArea.visible = false
	reset_all_items()

	match press_count:
		LEVEL.IN_THE_DARK:
			buzzer.in_the_dark()
		LEVEL.LIGHT_TOO_SOON:
			timer.start(duration - 1.0)
		LEVEL.NEED_POWER:
			new_buzzer_position = Vector2(150, 650)
			buzzer.display_led = true
			powerArea.visible = true
			buzzer.draggable = true
			buzzer.powered = false
		LEVEL.TINY:
			new_buzzer_position = random_position()
			buzzer.scale = Vector2(.05, .05)
		LEVEL.FALL:
			buzzer.draggable = true
			buzzer.physic_enable = true
			new_buzzer_position = Vector2(400, 200)
			buzzer.rotation = PI
		LEVEL.NO_COUNTER:
			count_down.visible = false
		LEVEL.NO_CAP:
			buzzer.with_cap = false
		LEVEL.NEED_POWER_MAZE:
			$BG/Maze.start()
			buzzer.display_led = true
			buzzer.powered = false
			buzzer.draggable = true
			buzzer.physics_collision = true
			buzzer.scale = Vector2(.15, .15)
			buzzer.global_position = Vector2(200, 600)
			new_buzzer_position = buzzer.global_position
		LEVEL.SHRINK_BOUNCE, LEVEL.BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
		LEVEL.RANDOM_BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
			start_random_timer()
		LEVEL.RANDOM_SHRINK_BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
			start_random_timer()
		LEVEL.TP_RANDOM:
			start_random_timer()
		LEVEL.FAKE_1:
			$BG/FakeBuzzers.start(0)
			new_buzzer_position = random_position()
		LEVEL.FAKE_2:
			$BG/FakeBuzzers.start(1)
			new_buzzer_position = random_position()
		LEVEL.FAKE_THE_RETURN:
			$BG/FakeBuzzers.start(2)
			new_buzzer_position = random_position()
		_:
			pass

	var key = dialog_key()
	dialog.visible = key != ""
	if key != "":
		dialog.text = tr("level-%s" % key)
		
	buzzer.global_position = new_buzzer_position
	buzzer.update_buzzer_state()
	level_end = false
	remaining = duration

func trigger_game_over() -> void:
	game_over = true
	Stats.nbr_attempt += 1
	dialog.text = tr(game_over_key())
	$AnimationPlayer.play("loose")

func power_buzzer(power: bool) -> void:
	buzzer.powered = power
	buzzer.update_led()

func dialog_key() -> String:
	match press_count:
		LEVEL.INTRO: return "intro-01"
		LEVEL.INTRO2: return "intro-02"
		LEVEL.INTRO3: return "intro-03"
	#	LEVEL.FALLING_OBJECT: return "falling-object"
		LEVEL.TP_RANDOM: return "td-random"
		LEVEL.RANDOM_SHRINK_BOUNCE: return "random-shrink-bounce"
		LEVEL.RANDOM_BOUNCE: return "random-bounce"
		LEVEL.BOUNCE: return "bounce"
		LEVEL.SHRINK_BOUNCE: return "shrink-bounce"
		LEVEL.SHRINK: return "shrink"
		LEVEL.FAKE_1: return "fake-01"
		LEVEL.FAKE_2: return "fake-02"
		LEVEL.FAKE_THE_RETURN: return "fake-03"
		LEVEL.NEED_POWER_MAZE: return "power-maze"
		LEVEL.TINY: return "tiny"
		LEVEL.TP_RANDOM_TINY: return "tp-random-tiny"
		LEVEL.NO_CAP: return "no-cap"
		LEVEL.NEED_POWER: return "need-power"
		LEVEL.FALL: return "fall"
		LEVEL.NO_COUNTER: return "no-counter"
		LEVEL.DONT_TURN_LIGHT: return "no-light"
		LEVEL.LIGHT_TOO_SOON: return "too-soon"
		LEVEL.IN_THE_DARK: return "pitch-black"
		_: return ""

func game_over_key() -> String:
	match press_count:
		LEVEL.INTRO, LEVEL.INTRO2, LEVEL.INTRO2:
			return "game-over-intro"
		LEVEL.LIGHT_TOO_SOON:
			return "game-over-too-soon"
		LEVEL.NO_CAP:
			return "game-over-no-cap"
		LEVEL.TINY, LEVEL.TP_RANDOM_TINY:
			return "game-over-tiny"
		_: return "game-over"

# CALLBACKS

func _on_Buzzer_pressed() -> void:
	press_count += 1
	Stats.nbr_click += 1
	level_end = true
	if !game_started:
		sticky.fall()
		buzzer.play_sound(true)
	else:
		if remaining <= 0 and (abs(remaining) <= extra_time):
			buzzer.play_sound(true)
		else:
			buzzer.play_sound(false)
			trigger_game_over()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	var _osef = get_tree().reload_current_scene()

func _on_Fade_finished(fade_in: bool) -> void:
	if !fade_in and press_count == LEVEL.VICTORY:
		var _osef = get_tree().change_scene("res://scenes/Victory.tscn")

func _on_Buzzer_drag_stopped() -> void:
	pass

func _on_Buzzer_drag_started() -> void:
	pass

func _on_PowerArea_entered() -> void:
	power_buzzer(true)

func _on_PowerArea_exited() -> void:
	power_buzzer(false)

func _on_Maze_entered() -> void:
	power_buzzer(true)

func _on_Maze_exited() -> void:
	power_buzzer(false)

func _on_Timer_timeout() -> void:
	match press_count:
		LEVEL.LIGHT_TOO_SOON:
			buzzer.turn_light(true)
		LEVEL.RANDOM_BOUNCE, LEVEL.RANDOM_SHRINK_BOUNCE:
			bouncing_direction = random_direction()
			start_random_timer()
		LEVEL.TP_RANDOM, LEVEL.TP_RANDOM_TINY:
			buzzer.global_position = random_position()
			if remaining >= 1.0:
				start_random_timer()

func _on_Buzzer_hidden_in_the_dark() -> void:
	match press_count:
		LEVEL.IN_THE_DARK:
			move_buzzer_at_random()

func _on_Buzzer_press_finished() -> void:
	if game_over:
		return
	match press_count:
		LEVEL.INTRO:
			if !game_started:
				start_game()
		LEVEL.VICTORY:
			fade.fade_out()
		_:
			next_level()
