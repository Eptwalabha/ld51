class_name FakeBuzzers
extends Node2D

var texture = load("res://assets/img/button-full.png")

func start(level: int) -> void:
	match level:
		0: spawn(1)
		1: spawn(4)
		2: spawn(50)
	visible = true

func spawn(n: int) -> void:
	for f in $fakes.get_children():
		f.hide()

	for i in range(n):
		var s = Sprite2D.new()
		s.texture = texture
		s.scale = Vector2(.5, .5)
		s.global_position = Vector2(100, 150) + Vector2(600 * randf(), 550 * randf())
		$fakes.add_child(s)

func reset() -> void:
	for f in $fakes.get_children():
		f.hide()
	visible = false
