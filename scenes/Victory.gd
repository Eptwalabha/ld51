extends Node2D

func _ready() -> void:
	$CanvasLayer/Fade.fade_in()
	var text = "[center]You made it![/center]\n\n" \
		+ "with [color=blue]{attempt}[/color] attempt(s)\n" \
		+ "you pressed the buzzer [color=blue]{click}[/color] times(s)\n" \
		+ "in [color=blue]{time}[/color] secondes"
	var data = {
		'attempt': Stats.nbr_attempt,
		'click': Stats.nbr_click,
		'time': str(int(Stats.total_time))
	}
	$Buzzer.turn_light()
	$CanvasLayer/Control/VBoxContainer/RichTextLabel.bbcode_text = text.format(data)

func _on_Buzzer_press_finished() -> void:
	Stats.nbr_attempt = 0
	Stats.nbr_click = 0
	Stats.total_time = 0.0
	$CanvasLayer/Fade.fade_out()

func _on_Fade_finished(fade_in) -> void:
	if !fade_in:
		var _osef = get_tree().change_scene("res://scenes/Game.tscn")
