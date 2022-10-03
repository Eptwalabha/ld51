extends Node2D


signal completed(time)
signal failed()

var time : float = 0.0
var total_time : float = 0.0
var game_started: bool = false
var game_over: bool = false

onready var count_down : Label = $"%CountDown"
onready var button : TheButton = $Button

export(float) var duration : float = 10.0
export(float) var allowed_delta : float = .8

func _ready() -> void:
	count_down.hide()
	button.light()
	game_started = false
	game_over = false
	time = 0.0
	total_time = 0.0

func _process(delta: float) -> void:
	if !game_started or game_over:
		return
	var remaining : float = duration - time
	
	if remaining < 0:
		button.light()
		if abs(remaining) > allowed_delta :
			remaining = allowed_delta
			game_over()
		update_count_down("-", abs(remaining))
	else:
		update_count_down("", remaining)

	time += delta

func update_count_down(count_sign: String, remaining: float) -> void:
	var second : int = int(floor(remaining))
	var milli : int = int(100.0 * fmod(remaining, 1.0))
	count_down.text = "%s %s.%s" % [count_sign, second, milli]

func _on_Button_clicked() -> void:
	if !game_started:
		button.reset()
		game_over = false
		count_down.visible = true
		game_started = true
	else:
		var remaining : float = time - duration
		if remaining >= 0.0 and remaining <= allowed_delta:
			button.reset()
			time = 0.0
		else:
			game_over()

func game_over() -> void:
	game_over = true
	$AnimationPlayer.play("loose")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_tree().change_scene("res://scenes/Game.tscn")
