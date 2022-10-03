class_name ButtonCap
extends Node2D

signal clicked

export(bool) var visible_stick := false
export(bool) var light_on := true

onready var stick : Sprite = $Stick
onready var cap : Sprite = $Cap
onready var tween : Tween = $Tween

func _ready() -> void:
	show_stick(visible_stick)
	_change_light(true)
	
func show_stick(show: bool) -> void:
	visible_stick = show
	stick.visible = show

func turn_light(on: bool, instant : bool = false) -> void:
	if on == light_on:
		return
	light_on = on
	_change_light(instant)

func _change_light(instant : bool) -> void:
	var color : Color = Color.white if light_on else Color("#888")
	if instant or !light_on:
		cap.modulate = color
	else:
		tween.interpolate_property(cap, 'modulate', cap.modulate, color, .1)
		tween.start()

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("clicked")
