class_name PowerArea
extends Node2D

signal entered
signal exited

func _on_Area2D_area_entered(_area: Area2D) -> void:
	if !visible:
		return
	emit_signal("entered")

func _on_Area2D_area_exited(_area: Area2D) -> void:
	if !visible:
		return
	emit_signal("exited")
