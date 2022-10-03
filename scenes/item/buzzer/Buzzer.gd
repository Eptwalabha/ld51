class_name Buzzer
extends Node2D

signal pressed

onready var light : Sprite = $"%Light"
onready var tween : Tween = $Tween

onready var cap : Sprite = $"Buzzer/Pivot/Button-base/Button-cap"
onready var stick : Sprite = $"Buzzer/Pivot/Button-base/Button-stick"

export(bool) var with_cap : bool = true
export(bool) var with_stick : bool = true
export(bool) var light_is_on: bool = false
export(bool) var draggable : bool = false

var pressing : bool = false

func _ready() -> void:
	update_buzzer_state()

func reset() -> void:
	with_cap = true
	with_stick = true
	_turn_light(light_is_on, true)

func play_sound(good: bool) -> void:
	if good:
		$Good.play()
	else:
		$Error.play()

func turn_light(on: bool = true, instant = false) -> void:
	if on == light_is_on:
		return
	_turn_light(on, instant)

func _turn_light(on: bool, instant : bool) -> void:
	light_is_on = on
	var to : float = 1.0 if light_is_on else 0.0
	tween.stop_all()
	if instant or !on:
		light.modulate.a = to
	else:
		tween.interpolate_property(light, "modulate:a", light.modulate.a, to, .15)
		tween.start()

func update_buzzer_state() -> void:
	cap.visible = with_cap
	stick.visible = !with_cap and with_stick

	$Buzzer/Click/Cap.disabled = !with_cap
	$Buzzer/Click/Stick.disabled = with_cap or !with_stick

func can_press() -> bool:
	if pressing:
		return false
	return with_cap or with_stick

func _on_Click_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if can_press():
			pressing = true
			$AnimationPlayer.play("press")
			emit_signal("pressed")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == 'press':
		pressing = false


func _on_Base_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if draggable:
			print("drag")
