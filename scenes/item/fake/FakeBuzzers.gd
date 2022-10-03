class_name FakeBuzzers
extends Node2D

var texture = load("res://assets/img/button-full.png")

func _ready() -> void:
	for i in range(40):
		var s = Sprite.new()
		s.texture = texture
		s.scale = Vector2(.5, .5)
		s.global_position = Vector2(-50, -50) + Vector2(900 * randf(), 900 * randf())
		add_child(s)

func start() -> void:
	visible = true

func reset() -> void:
	visible = false
