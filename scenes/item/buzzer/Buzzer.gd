class_name Buzzer
extends CharacterBody2D

signal pressed
signal press_finished
signal drag_started
signal drag_stopped
signal hidden_in_the_dark

@onready var light : Sprite2D = $"%Light3D"
@onready var led : Node2D = $"%Led"
@onready var pivot : Node2D = $Pivot

@onready var cap : Sprite2D = $"Pivot/Button-base/Button-cap"
@onready var stick : Sprite2D = $"Pivot/Button-base/Button-stick"

@export var with_cap: bool = true
@export var with_stick: bool = true
@export var light_is_on: bool = false
@export var draggable: bool = false
@export var powered: bool = true

var physic_enable : bool = false
var physics_collision : bool = false
var pressing : bool = false
var dragging : bool = false
var delta_drag : Vector2 = Vector2.ZERO
var display_led: bool = false
var buzz_velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	update_buzzer_state()

func reset() -> void:
	with_cap = true
	with_stick = true
	draggable = false
	dragging = false
	display_led = false
	physic_enable = false
	physics_collision = false
	update_buzzer_state()
	pivot.modulate = Color.WHITE
	_turn_light(light_is_on, true)

func play_sound(good: bool) -> void:
	if good:
		$Good.play()
	else:
		$Error.play()

func in_the_dark() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(pivot, 'modulate', Color.BLACK, 1.0)
	await get_tree().create_timer(1.5).timeout
	emit_signal("hidden_in_the_dark")

func turn_light(on: bool = true, instant = false) -> void:
	if !powered or on == light_is_on:
		return
	_turn_light(on, instant)

func _turn_light(on: bool, instant : bool) -> void:
	light_is_on = on
	var to : float = 1.0 if light_is_on else 0.0
	if instant or !on:
		light.modulate.a = to
	else:
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(light, "modulate:a", to, .15)

func _physics_process(delta: float) -> void:
	if draggable and dragging:
		buzz_velocity = Vector2.ZERO
		if physics_collision:
			var diff = (get_global_mouse_position() - global_position) * (1.0 / scale.x)
			set_velocity(diff)
			move_and_slide()
		else:
			global_position = lerp(global_position, get_global_mouse_position() + delta_drag, 50 * delta)
	elif physic_enable:
		buzz_velocity.y += delta * 8.0
		move_and_collide(buzz_velocity)

func update_buzzer_state() -> void:
	cap.visible = with_cap
	stick.visible = !with_cap and with_stick
	light.visible = with_cap
	$Click/Cap.disabled = !with_cap
	$Click/Stick.disabled = with_cap or !with_stick
	$Physics.disabled = !physic_enable and !physics_collision
	update_led()

func update_led() -> void:
	led.visible = display_led
	led.get_node("Led-on").visible = powered
	led.get_node("Led-off").visible = !powered

func can_press() -> bool:
	if pressing:
		return false
	if powered:
		return with_cap or with_stick
	return false

func do_press() -> void:
	if can_press():
		pressing = true
		$AnimationPlayer.play("press")
		if powered:
			emit_signal("pressed")

func _on_Click_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		do_press()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == 'press':
		pressing = false
		emit_signal('press_finished')

func _on_Base_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if !draggable:
		return
	if event is InputEventMouseButton:
		if event.is_action_pressed('touch'):
			emit_signal("drag_started")
			delta_drag = global_position - get_global_mouse_position()
			dragging = true
		elif event.is_action_released('touch'):
			emit_signal("drag_stopped")
			dragging = false


func _on_Click_body_entered(body: Node) -> void:
	if physic_enable or physics_collision:
		if body != self:
			do_press()
