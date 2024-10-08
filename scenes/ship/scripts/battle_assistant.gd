class_name BattleAssistant
extends Node

@export var pointer_view: AssistantPointer

@onready var ship: Spaceship = owner

var gun: Gun
var target: Spaceship
var shoot_point := Vector2.ZERO
var _is_auto_aim := false
var is_auto_shoot := false

var enabled := false
var _last_delta_velocity := Vector2.ZERO

func _ready():
	_disable_pointer()


func _process(_delta):
	if not enabled: return
	_calculate_bullet_intersection()
	auto_aim()
	auto_shoot()


func connect_inputs(inputs: ShipInput):
	inputs.auto_aim.connect(_auto_aim_toggle)
	inputs.reset_target.connect(_reset_target)
	enabled = true


func set_target(new_target: RigidBody2D):
	target = new_target


func auto_aim():
	if _is_auto_aim and shoot_point != Vector2.ZERO:
		ship.flight_assistant.ignore_direction_update = true
		ship.flight_assistant.direction = shoot_point + ship.position
	else:
		ship.flight_assistant.ignore_direction_update = false


func auto_shoot():
	if not is_instance_valid(gun): return
	if not is_auto_shoot: return
	if is_instance_valid(target)\
			and abs(ship.transform.x.angle_to(shoot_point)) < 1\
			and shoot_point.length() < gun.range + _get_delta_v().project(ship.transform.x).length():
		gun._is_firing = true
	else:
		gun._is_firing = false


func _calculate_bullet_intersection():
	if not is_instance_valid(gun): return
	# TODO: Refactor this garbage
	shoot_point = Vector2.ZERO
	if not(is_instance_valid(target) and target is RigidBody2D):
		_disable_pointer()
		return
	var dv := _get_delta_v()
	var a := dv.length_squared() - gun.bullet_speed * gun.bullet_speed
	if a == 0.0:
		_disable_pointer()
		return
	#var Pd = target.extrapolator.position - ship.extrapolator.position
	#var t = 
	var to_target = target.position - ship.position
	var b = 2 * to_target.dot(dv)
	var c = to_target.length_squared()
	var discriminant = b * b - 4 * a * c
	if discriminant >= 0:
		var t1 = (-b + sqrt(discriminant)) / (2 * a)
		var t2 = (-b - sqrt(discriminant)) / (2 * a)
		var t = min(t1, t2)
		if t < 0:
			t = max(t1, t2)
		if t >= 0:
			shoot_point = to_target + dv * t
			_update_pointer(shoot_point, shoot_point.length() < gun.range)
			return
	_disable_pointer()

func _get_delta_v() -> Vector2:
	return target.absolute_velocity - ship.absolute_velocity

func _disable_pointer():
	if is_instance_valid(pointer_view):
		pointer_view.disable()

func _update_pointer(point: Vector2, in_range: bool):
	if is_instance_valid(pointer_view):
		pointer_view.update(point, ship.canvas_position, in_range)

func _auto_aim_toggle(value: bool):
	if not value: return
	_is_auto_aim = not _is_auto_aim

func _reset_target(value: bool):
	if not value: return
	target = null
