extends Node2D

signal completed(time)
signal failed()

#var time : float = 0.0
var remaining: float = 0.0
var total_time : float = 0.0

var game_started: bool = false
var game_over: bool = false
var press_count: int = 0
var level_end: bool = true

onready var count_down : Label = $"%CountDown"
onready var dialog : RichTextLabel = $"%Dialog"
onready var buzzer : Buzzer = $"%Buzzer"
onready var sticky : StickyNote = $"%Sticky"
onready var fade : Fade = $"%Fade"
onready var eptwalabha : Label = $"%Eptwalabha"
onready var powerArea : PowerArea = $BG/PowerArea

export(float) var duration : float = 10.0
export(float) var extra_time : float = 1.0

enum LEVEL {
	NOTHING,
	INTRO,
	INTRO2,
	MOVE_AROUND,
	MOVE_AT_RANDOM,
	NO_CAP,
	NEED_POWER,
	NO_COUNTER,
	DONT_TURN_LIGHT,
	LIGHT_TOO_SOON,
	IN_THE_DARK,
}

func _ready() -> void:
	count_down.hide()
	buzzer.turn_light(true, true)
	fade.fade_in()

func _process(delta: float) -> void:
	if !game_started or game_over or level_end:
		return

	if remaining <= 0:
		turn_on_buzzer_light()
		if abs(remaining) > extra_time :
			remaining = extra_time
			buzzer.turn_light(false)
			game_over()
	update_count_down()
	remaining -= delta

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
	buzzer.global_position = Vector2(100, 200) + Vector2(600, 400) * randf()

func next_level() -> void:
	buzzer.reset()
	buzzer.rotation = 0
	var new_buzzer_position: = Vector2(400, 600)
	buzzer.turn_light(false)
	count_down.visible = true
	powerArea.visible = false
	match press_count:
		LEVEL.IN_THE_DARK:
			buzzer.in_the_dark()
		LEVEL.LIGHT_TOO_SOON:
			$Timer.start(2.0)
		LEVEL.NEED_POWER:
			buzzer.display_led = true
			powerArea.visible = true
			buzzer.draggable = true
			buzzer.powered = false
		LEVEL.NO_COUNTER:
			count_down.visible = false
		LEVEL.NO_CAP:
			buzzer.with_cap = false
	buzzer.global_position = new_buzzer_position
	buzzer.update_buzzer_state()
	level_end = false
	remaining = duration

func game_over() -> void:
	game_over = true
	$AnimationPlayer.play("loose")


# CALLBACKS

func _on_Buzzer_pressed() -> void:
	press_count += 1
	level_end = true
	if !game_started:
		sticky.fall()
		buzzer.play_sound(true)
	else:
		if remaining <= 0 and (abs(remaining) <= extra_time):
			buzzer.play_sound(true)
		else:
			buzzer.play_sound(false)
			game_over()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	var _osef = get_tree().change_scene("res://scenes/Game.tscn")

func _on_Fade_finished(_fade_in: bool) -> void:
	pass

func _on_Buzzer_drag_stopped() -> void:
	pass

func _on_Buzzer_drag_started() -> void:
	pass

func _on_PowerArea_entered() -> void:
	buzzer.powered = true
	buzzer.update_led()

func _on_PowerArea_exited() -> void:
	buzzer.powered = false
	buzzer.update_led()

func _on_Timer_timeout() -> void:
	match press_count:
		LEVEL.LIGHT_TOO_SOON:
			buzzer.turn_light(true)

func _on_Buzzer_hidden_in_the_dark() -> void:
	match press_count:
		LEVEL.IN_THE_DARK:
			move_buzzer_at_random()

func _on_Buzzer_press_finished() -> void:
	if game_over:
		return
	if press_count == LEVEL.INTRO:
		start_game()
	else:
		next_level()
