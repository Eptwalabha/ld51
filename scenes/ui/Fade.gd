class_name Fade
extends Control

signal finished(fade_in)

@export var duration: float = 2.0

@onready var rect : ColorRect = $ColorRect

func _enter_tree() -> void:
	$ColorRect.modulate.a = 1.0

func fade_in(instant : bool = false) -> void:
	if instant:
		rect.modulate.a = 0.0
		finished.emit()
	else:
		fade_from_to(1.0, 0.0)

func fade_out(instant : bool = false) -> void:
	if instant:
		rect.modulate.a = 1.0
		finished.emit()
	else:
		fade_from_to(0.0, 1.0)

func fade_from_to(alpha_from: float, alpha_to: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.finished.connect(self._on_Tween_tween_all_completed)
	rect.modulate.a = alpha_from
	tween.tween_property(rect, 'modulate:a', alpha_to, duration)

func _on_Tween_tween_all_completed() -> void:
	emit_signal("finished", rect.modulate.a < 1.0)
