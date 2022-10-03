class_name TheButton
extends Node2D

signal clicked

onready var cap : ButtonCap = $Pivot/ButtonBase/ButtonCap

func _ready() -> void:
	reset()

func reset() -> void:
	cap.turn_light(false)

func _on_ButtonCap_clicked() -> void:
	$AnimationPlayer.play("click")
	$Ok.play()
	emit_signal("clicked")

func light(light: bool = true) -> void:
	cap.turn_light(light)

func _on_ButtonStick_clicked() -> void:
	$AnimationPlayer.play("click")
	$Ok.play()
	emit_signal("clicked")
