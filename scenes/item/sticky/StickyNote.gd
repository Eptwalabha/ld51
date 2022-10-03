class_name StickyNote
extends Node2D

func fall() -> void:
	$AnimationPlayer.play("fall")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "fall":
		queue_free()
