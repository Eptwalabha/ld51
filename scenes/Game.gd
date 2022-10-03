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
onready var button : TheButton = $Button
onready var fade : Fade = $CanvasLayer/Control/Fade

export(float) var duration : float = 10.0
export(float) var allowed_delta : float = 1.0

func _ready() -> void:
	count_down.hide()
	button.light()
	fade.fade_in()

func _process(delta: float) -> void:
	if !game_started or game_over:
		return
	
	if remaining <= 0:
		button.light()
		if abs(remaining) > allowed_delta :
			remaining = allowed_delta
			game_over()
	update_count_down()
	remaining -= delta

func update_count_down() -> void:
	var count_sign : String = "" if remaining > 0 else "-"
	var second : int = int(floor(abs(remaining)))
	var milli : int = int(100.0 * fmod(abs(remaining), 1.0))
	count_down.text = "%s%s.%s" % [count_sign, second, milli]

func _on_Button_clicked() -> void:
	press_count += 1
	if !game_started:
		start_game()
	else:
		if remaining <= 0 and (abs(remaining) <= allowed_delta):
			next_level()
		else:
			game_over()

func start_game() -> void:
	$CanvasLayer/Control/Eptwalabha.visible = false
	next_level()

func next_level() -> void:
	game_started = true
	button.reset()
	remaining = duration
	count_down.visible = true

func game_over() -> void:
	game_over = true
	$AnimationPlayer.play("loose")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_Fade_finished(fade_in: bool) -> void:
	pass
