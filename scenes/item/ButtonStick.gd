class_name ButtonStick
extends Node2D

signal clicked

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("clicked")
