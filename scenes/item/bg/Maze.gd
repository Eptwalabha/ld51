class_name Maze
extends StaticBody2D

@onready var power_area: PowerArea = $PowerArea


func _ready() -> void:
	$Collision.polygon = $Polygon2D.polygon

func start() -> void:
	visible = true
	power_area.activate()
	$Collision.disabled = false

func reset() -> void:
	visible = false
	power_area.reset()
	$Collision.disabled = true

func get_starting_position() -> Vector2:
	return $Start.global_position
