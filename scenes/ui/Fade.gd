class_name Fade
extends Control

signal finished(fade_in)

export(float) var duration : float = 2.0

onready var rect : ColorRect = $ColorRect
onready var tween : Tween = $Tween

func _enter_tree() -> void:
	$ColorRect.color.a = 1.0

func fade_in(instant : bool = false) -> void:
	if instant:
		rect.color.a = 0.0
		emit_signal("finished")
	else:
		fade_from_to(1.0, 0.0)

func fade_out(instant : bool = false) -> void:
	if instant:
		rect.color.a = 1.0
		emit_signal("finished")
	else:
		fade_from_to(0.0, 1.0)

func fade_from_to(alpha_from: float, alpha_to: float) -> void:
	tween.interpolate_property(rect, 'color:a', alpha_from, alpha_to, duration)
	tween.start()

func _on_Tween_tween_all_completed() -> void:
	emit_signal("finished", rect.color.a < 1.0)
