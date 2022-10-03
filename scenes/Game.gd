extends Node2D

signal completed(time)
signal failed()

#var time : float = 0.0
var remaining: float = 0.0
var total_time : float = 0.0

var game_started: bool = false
var game_over: bool = false
var press_count: int = 0

onready var count_down : Label = $"%CountDown"
onready var dialog : RichTextLabel = $"%Dialog"
onready var buzzer : Buzzer = $"%Buzzer"
onready var sticky : StickyNote = $"%Sticky"
onready var fade : Fade = $"%Fade"
onready var eptwalabha : Label = $"%Eptwalabha"

export(float) var duration : float = 10.0
export(float) var extra_time : float = 1.0

func _ready() -> void:
	count_down.hide()
	buzzer.turn_light(true, true)
	fade.fade_in()

func _process(delta: float) -> void:
	if !game_started or game_over:
		return

	if remaining <= 0:
		buzzer.turn_light()
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

func _on_Buzzer_pressed() -> void:
	press_count += 1
	if !game_started:
		buzzer.play_sound(true)
		start_game()
	else:
		if remaining <= 0 and (abs(remaining) <= extra_time):
			buzzer.play_sound(true)
			next_level()
		else:
			buzzer.play_sound(false)
			game_over()

func start_game() -> void:
	eptwalabha.visible = false
	next_level()

func next_level() -> void:
	if press_count == 1:
		sticky.fall()
	game_started = true
	buzzer.reset()
	buzzer.turn_light(false)
	remaining = duration
	count_down.visible = true

func game_over() -> void:
	game_over = true
	$AnimationPlayer.play("loose")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	var _osef = get_tree().change_scene("res://scenes/Game.tscn")

func _on_Fade_finished(_fade_in: bool) -> void:
	pass

