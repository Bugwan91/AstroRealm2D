class_name BattleAssistant
extends Node

@export var gun: Gun

@onready var ship: ShipRigidBody = owner
@onready var pointer: BattleAssistantPointer = %Pointer

var target: RigidBody2D

func _ready():
	pointer.disable()


func _process(_delta):
	_calculate_bullet_intersection()
	pointer.position = ship.position


func set_target(value: RigidBody2D):
	target = value


func _calculate_bullet_intersection():
	if not(is_instance_valid(target) and target is RigidBody2D):
		pointer.disable()
		return
	var relative_target_vel = target.linear_velocity - ship.linear_velocity
	var a = relative_target_vel.length_squared() - gun.bullet_speed * gun.bullet_speed
	if a == 0.0:
		pointer.disable()
		return
	var to_target = target.position - ship.position
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
			var intercept_pos = to_target + relative_target_vel * t
			pointer.update(intercept_pos, intercept_pos.length() < gun.range)
			return
	pointer.disable()
