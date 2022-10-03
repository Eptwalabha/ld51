class_name StickyNote
extends Sprite

func fall() -> void:
	$AnimationPlayer.play("fall")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "fall":
		queue_free()
