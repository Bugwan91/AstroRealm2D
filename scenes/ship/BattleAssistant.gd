class_name BattleAssistant
extends Node

@export var gun: Gun

@onready var ship: ShipRigidBody = owner
@onready var pointer: BattleAssistantPointer = %Pointer

var target: RigidBody2D
var shoot_point: Vector2


func _ready():
	_disable_pointer()


func _process(_delta):
	pointer.position = ship.extrapolated_position
	_calculate_bullet_intersection()


func set_target(new_target: RigidBody2D):
	target = new_target


func _calculate_bullet_intersection():
	if not(is_instance_valid(target) and target is RigidBody2D):
		_disable_pointer()
		return
	var relative_target_vel = target.linear_velocity - ship.linear_velocity
	var a = relative_target_vel.length_squared() - gun.bullet_speed * gun.bullet_speed
	if a == 0.0:
		_disable_pointer()
		return
	var to_target = target.position - ship.extrapolated_position
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
			_update_pointer(shoot_point, shoot_point.length() < gun.range)
			return
	_disable_pointer()

func _disable_pointer():
	if is_instance_valid(pointer):
		pointer.disable()

func _update_pointer(point: Vector2, in_range: bool):
	if is_instance_valid(pointer):
		pointer.update(point, in_range)
