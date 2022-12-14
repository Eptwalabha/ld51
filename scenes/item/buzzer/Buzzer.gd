class_name Buzzer
extends KinematicBody2D

signal pressed
signal press_finished
signal drag_started
signal drag_stopped
signal hidden_in_the_dark

onready var light : Sprite = $"%Light"
onready var led : Node2D = $"%Led"
onready var tween : Tween = $Tween
onready var pivot : Node2D = $Pivot

onready var cap : Sprite = $"Pivot/Button-base/Button-cap"
onready var stick : Sprite = $"Pivot/Button-base/Button-stick"

export(bool) var with_cap : bool = true
export(bool) var with_stick : bool = true
export(bool) var light_is_on: bool = false
export(bool) var draggable : bool = false
export(bool) var powered : bool = true

var physic_enable : bool = false
var physics_collision : bool = false
var pressing : bool = false
var dragging : bool = false
var delta_drag : Vector2 = Vector2.ZERO
var display_led: bool = false
var velocity : Vector2 = Vector2.ZERO

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
	pivot.modulate = Color.white
	_turn_light(light_is_on, true)

func play_sound(good: bool) -> void:
	if good:
		$Good.play()
	else:
		$Error.play()

func in_the_dark() -> void:
	tween.interpolate_property(pivot, 'modulate', pivot.modulate, Color.black, 1.0)
	tween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	emit_signal("hidden_in_the_dark")

func turn_light(on: bool = true, instant = false) -> void:
	if !powered or on == light_is_on:
		return
	_turn_light(on, instant)

func _turn_light(on: bool, instant : bool) -> void:
	light_is_on = on
	var to : float = 1.0 if light_is_on else 0.0
	tween.stop_all()
	if instant or !on:
		light.modulate.a = to
	else:
		tween.interpolate_property(light, "modulate:a", light.modulate.a, to, .15)
		tween.start()

func _physics_process(delta: float) -> void:
	if draggable and dragging:
		velocity = Vector2.ZERO
		if physics_collision:
			var diff = (get_global_mouse_position() - global_position) * (1.0 / scale.x)
			move_and_slide(diff)
		else:
			global_position = lerp(global_position, get_global_mouse_position() + delta_drag, 50 * delta)
	elif physic_enable:
		velocity.y += delta * 8.0
		move_and_collide(velocity)

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

