class_name BattleAssistant
extends Node

@export var pointer_view: AssistantPointer

@onready var ship: ShipRigidBody = owner
@onready var _main_state: MainState = get_node("/root/MainState")

var gun: Gun
var target: ShipRigidBody
var shoot_point := Vector2.ZERO
var shoot_point_2 := Vector2.ZERO
var aim_accuracy := 1.0
var aim_accuracy_damp := 0.1
var _is_auto_aim := false
var is_auto_shoot := false

var enabled := false
var _last_delta_velocity := Vector2.ZERO
var _aim_error := 0.0

func _update_aim_error(delta: float):
	if is_instance_valid(target):
		var dv := target.linear_velocity - ship.linear_velocity
		var dv_a := dv - _last_delta_velocity
		_last_delta_velocity = dv
		var rate = (dv_a / dv).length() * 0.1 # too large
		_aim_error = clamp(_aim_error + rate, 0.0, 1.0)
		_aim_error = max(0.0, _aim_error - 0.01)

func _ready():
	_disable_pointer()


func _process(delta):
	if not enabled: return
	_calculate_bullet_intersection()
	auto_aim()
	auto_shoot()

func _physics_process(delta):
	_update_aim_error(delta)


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
	if not is_auto_shoot: return
	if is_instance_valid(target)\
			and abs(ship.transform.x.angle_to(shoot_point)) < 1\
			and shoot_point.length() < gun.range + _get_delta_v().project(ship.transform.x).length():
		gun._is_firing = true
	else:
		gun._is_firing = false


func _calculate_bullet_intersection():
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
	var to_target = target.extrapolator.smooth_position - ship.extrapolator.smooth_position
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


func _calculate_bullet_intersection_2():
	# TODO: Refactor this garbage
	shoot_point_2 = Vector2.ZERO
	if not(is_instance_valid(target) and target is RigidBody2D):
		return
	var dv := _get_delta_v()
	var a := dv.length_squared() - gun.bullet_speed * gun.bullet_speed
	if a == 0.0:
		return
	var to_target = target.extrapolator.smooth_position - ship.extrapolator.smooth_position
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
			shoot_point_2 = to_target + dv * t
			#DebugDraw2d.line_vector(ship.extrapolator.smooth_position, shoot_point, Color.RED)
			#DebugDraw2d.line_vector(ship.extrapolator.smooth_position, shoot_point_2, Color.GREEN)
			return

func _get_delta_v() -> Vector2:
	return target.linear_velocity - ship.linear_velocity

func _disable_pointer():
	if is_instance_valid(pointer_view):
		pointer_view.disable()

func _update_pointer(point: Vector2, in_range: bool):
	if is_instance_valid(pointer_view):
		pointer_view.update(point, ship.extrapolator.canvas_position, in_range)

func _auto_aim_toggle(value: bool):
	if not value: return
	_is_auto_aim = not _is_auto_aim

func _reset_target(value: bool):
	if not value: return
	target = null
