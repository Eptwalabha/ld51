class_name PowerArea
extends Node2D

var active : bool = false

func activate() -> void:
	active = true
	visible = true

func reset() -> void:
	active = false
	visible = false

func _on_Area2D_area_entered(area: Area2D) -> void:
	if visible and active:
		EventsBus.buzzer_powered.emit(true)

func _on_Area2D_area_exited(_area: Area2D) -> void:
	if visible and active:
		EventsBus.buzzer_powered.emit(false)
