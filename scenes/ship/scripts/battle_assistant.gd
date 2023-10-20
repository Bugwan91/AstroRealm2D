class_name BattleAssistant
extends Node

@onready var ship: ShipRigidBody = owner
@onready var pointer: BattleAssistantPointer = %Pointer

var gun: Gun
var target: RigidBody2D
var shoot_point := Vector2.ZERO
var is_show_point := false

var _is_auto_aim := false
var is_auto_shoot := false

var _last_target_velocity := Vector2.ZERO
var _last_velocity := Vector2.ZERO

func _ready():
	_disable_pointer()


func _process(delta):
	pointer.position = ship.extrapolator.global_position
	_calculate_bullet_intersection()
	auto_aim()


func connect_inputs(inputs: ShipInput):
	inputs.auto_aim.connect(_auto_aim_toggle)


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


func _calculate_bullet_intersection():
	# TODO: Refactor this garbage
	shoot_point = Vector2.ZERO
	if not(is_instance_valid(target) and target is RigidBody2D):
		_disable_pointer()
		return
	var relative_target_vel = target.linear_velocity - ship.linear_velocity
	var a = relative_target_vel.length_squared() - gun.bullet_speed * gun.bullet_speed
	if a == 0.0:
		_disable_pointer()
		return
	var to_target = target.extrapolator.global_position - ship.extrapolator.global_position
	var b = 2 * to_target.dot(relative_target_vel)
	var c = to_target.length_squared()
	var discriminant = b * b - 4 * a * c
	if discriminant >= 0:
		var t1 = (-b + sqrt(discriminant)) / (2 * a)
		var t2 = (-b - sqrt(discriminant)) / (2 * a)
		var t = min(t1, t2)
		if t < 0:
			t = max(t1, t2)
		if t >= 0:
			shoot_point = to_target + relative_target_vel * t
			+ (0.5 * (target.linear_velocity - _last_target_velocity) * t * t)
			+ (0.5 * (ship.linear_velocity - _last_velocity) * t * t)
			#shoot_point = to_target + (0.5 * (target.linear_velocity - _last_velocity) * t * t)
			_last_target_velocity = target.linear_velocity
			_last_velocity = ship.linear_velocity
			_update_pointer(shoot_point, shoot_point.length() < gun.range)
			return
	_disable_pointer()

func _disable_pointer():
	if is_instance_valid(pointer):
		pointer.disable()

func _update_pointer(point: Vector2, in_range: bool):
	if is_show_point and is_instance_valid(pointer):
		pointer.update(point, in_range)

func _auto_aim_toggle(value: bool):
	if not value: return
	_is_auto_aim = not _is_auto_aim
