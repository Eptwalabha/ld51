extends Node2D

var remaining: float = 0.0
var b_scale: Vector2 = Vector2(.5, .5)
var bouncing_direction: Vector2 = Vector2.UP
var moving_speed : float = 200.0

@onready var count_down : Label = $"%CountDown"
@onready var dialog : Label = $"%Dialog"
@onready var buzzer : Buzzer = $"%Buzzer"
@onready var fade : Fade = $"%Fade"
@onready var eptwalabha : Label = $"%Eptwalabha"
@onready var powerArea : PowerArea = $BG/PowerArea
@onready var timer : Timer = $Timer
@onready var mute : CheckBox = $"%Mute"

@export var shrink_curve: Curve
@export var duration: float = 10.0
@export var extra_time: float = 1.0
@export var extra_start: float = 0.2

enum GAME_STATE {
	TITLE_SCREEN,
	COUNT_DOWN,
	EXTRA_TIME,
	BETWEEN_LEVEl,
	GAME_OVER,
	VICTORY
}

var game_state : GAME_STATE = GAME_STATE.TITLE_SCREEN
var current_level_index: int = 0
var current_level: Level.LEVEL_NAME

func _ready() -> void:
	current_level = Level.levels[current_level_index]
	AudioServer.set_bus_mute(0, Stats.mute)
	mute.button_pressed = Stats.mute
	randomize()
	count_down.hide()
	buzzer.turn_light(true, true)
	reset_all_items()
	fade.fade_in()

func _process(delta: float) -> void:
	if game_state != GAME_STATE.COUNT_DOWN and game_state != GAME_STATE.EXTRA_TIME:
		return

	if remaining <= extra_time and game_state == GAME_STATE.COUNT_DOWN:
		turn_on_buzzer_light()
		game_state = GAME_STATE.EXTRA_TIME

	if remaining <= 0.0:
		remaining = 0.0
		game_state = GAME_STATE.GAME_OVER
		buzzer.turn_light(false)
		trigger_game_over(true)


	update_buzzer(delta)
	update_count_down()
	remaining -= delta
	Stats.total_time += delta

func update_buzzer(delta: float) -> void:
	match current_level:
		Level.LEVEL_NAME.SHRINK:
			update_buzzer_scale()
		Level.LEVEL_NAME.BOUNCE, \
		Level.LEVEL_NAME.RANDOM_BOUNCE:
			bounce_buzzer(delta)
		Level.LEVEL_NAME.SHRINK_BOUNCE, \
		Level.LEVEL_NAME.RANDOM_SHRINK_BOUNCE:
			update_buzzer_scale()
			bounce_buzzer(delta)

func update_buzzer_scale() -> void:
	var true_remaining = min(duration, remaining - extra_time)
	var x = min(1.0, (duration - true_remaining) / duration)
	buzzer.scale = b_scale * shrink_curve.sample(x)

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
	count_down.text = "%.2f" % max(0.0, min(duration, remaining - extra_time))

func start_game() -> void:
	eptwalabha.visible = false
	next_level()

func turn_on_buzzer_light() -> void:
	if current_level == Level.LEVEL_NAME.DONT_TURN_LIGHT:
		return
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

	match current_level:
		Level.LEVEL_NAME.IN_THE_DARK:
			buzzer.in_the_dark()
		Level.LEVEL_NAME.LIGHT_TOO_SOON:
			timer.start(duration - 2.0)
		Level.LEVEL_NAME.NEED_POWER:
			new_buzzer_position = Vector2(150, 650)
			buzzer.display_led = true
			powerArea.visible = true
			buzzer.draggable = true
			buzzer.powered = false
		Level.LEVEL_NAME.TINY:
			new_buzzer_position = random_position()
			buzzer.scale = Vector2(.05, .05)
		Level.LEVEL_NAME.FALL:
			buzzer.draggable = true
			buzzer.physic_enable = true
			new_buzzer_position = Vector2(400, 200)
			buzzer.rotation = PI
		Level.LEVEL_NAME.NO_COUNTER:
			count_down.visible = false
		Level.LEVEL_NAME.NO_CAP:
			buzzer.with_cap = false
		Level.LEVEL_NAME.NEED_POWER_MAZE:
			$BG/Maze.start()
			buzzer.display_led = true
			buzzer.powered = false
			buzzer.draggable = true
			buzzer.physics_collision = true
			buzzer.scale = Vector2(.15, .15)
			buzzer.global_position = Vector2(200, 600)
			new_buzzer_position = buzzer.global_position
		Level.LEVEL_NAME.SHRINK_BOUNCE, Level.LEVEL_NAME.BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
		Level.LEVEL_NAME.RANDOM_BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
			start_random_timer()
		Level.LEVEL_NAME.RANDOM_SHRINK_BOUNCE:
			bouncing_direction = random_direction()
			new_buzzer_position = random_position()
			start_random_timer()
		Level.LEVEL_NAME.TP_RANDOM:
			new_buzzer_position = random_position()
			start_random_timer()
		Level.LEVEL_NAME.TP_RANDOM_TINY:
			new_buzzer_position = random_position()
			buzzer.scale = Vector2(.05, .05)
			start_random_timer()
		Level.LEVEL_NAME.FAKE_1:
			$BG/FakeBuzzers.start(0)
			new_buzzer_position = random_position()
		Level.LEVEL_NAME.FAKE_2:
			$BG/FakeBuzzers.start(1)
			new_buzzer_position = random_position()
		Level.LEVEL_NAME.FAKE_THE_RETURN:
			$BG/FakeBuzzers.start(2)
			new_buzzer_position = random_position()
		_:
			pass

	var key = Level.get_dialog(current_level)
	if key == "":
		dialog.visible = false
	else:
		dialog.visible = true
		dialog.text = tr("level-%s" % key)
		
	buzzer.global_position = new_buzzer_position
	buzzer.update_buzzer_state()
	game_state = GAME_STATE.COUNT_DOWN
	remaining = duration + extra_time + extra_start

func trigger_game_over(instant: bool) -> void:
	Stats.nbr_attempt += 1
	dialog.text = tr(Level.get_game_over_dialog(current_level))
	if not instant:
		await get_tree().create_timer(0.5).timeout
	$AnimationPlayer.play("loose")

func power_buzzer(power: bool) -> void:
	buzzer.powered = power
	buzzer.update_led()

# CALLBACKS

func _on_Buzzer_pressed() -> void:
	Stats.nbr_click += 1
	match game_state:
		GAME_STATE.GAME_OVER:
			buzzer.play_sound(false)
		GAME_STATE.TITLE_SCREEN:
			%StickyNote.fall()
			buzzer.play_sound(true)
		GAME_STATE.VICTORY:
			buzzer.play_sound(true)
		_:
			if remaining <= extra_time:
				buzzer.play_sound(true)
				current_level_index += 1
				if Level.has_next_level(current_level_index):
					game_state = GAME_STATE.VICTORY
				else:
					current_level = Level.levels[current_level_index]
					game_state = GAME_STATE.BETWEEN_LEVEl
			else:
				game_state = GAME_STATE.GAME_OVER
				buzzer.play_sound(false)
				trigger_game_over(false)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	get_tree().reload_current_scene()

func _on_Fade_finished(fade_in: bool) -> void:
	if !fade_in and game_state == GAME_STATE.VICTORY:
		get_tree().change_scene_to_file("res://scenes/Victory.tscn")

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
	match current_level:
		Level.LEVEL_NAME.LIGHT_TOO_SOON:
			buzzer.turn_light(true)
		Level.LEVEL_NAME.RANDOM_BOUNCE, Level.LEVEL_NAME.RANDOM_SHRINK_BOUNCE:
			bouncing_direction = random_direction()
			start_random_timer()
		Level.LEVEL_NAME.TP_RANDOM, Level.LEVEL_NAME.TP_RANDOM_TINY:
			buzzer.global_position = random_position()
			if remaining >= (extra_time + 1.0):
				start_random_timer()

func _on_Buzzer_hidden_in_the_dark() -> void:
	if current_level == Level.LEVEL_NAME.IN_THE_DARK:
		move_buzzer_at_random()

func _on_Buzzer_press_finished() -> void:
	match game_state:
		GAME_STATE.GAME_OVER:
			return
		GAME_STATE.TITLE_SCREEN:
			start_game()
		GAME_STATE.VICTORY:
			fade.fade_out()
		_:
			next_level()


func _on_CheckBox_pressed() -> void:
	AudioServer.set_bus_mute(0, mute.button_pressed)
	Stats.mute = mute.button_pressed
