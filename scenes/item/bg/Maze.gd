class_name Maze
extends StaticBody2D

signal entered
signal exited

func start() -> void:
	visible = true
	$Collision.disabled = false

func reset() -> void:
	visible = false
	$Collision.disabled = true

func _on_PowerArea_entered() -> void:
	emit_signal("entered")
	
func _on_PowerArea_exited() -> void:
	emit_signal("exited")
