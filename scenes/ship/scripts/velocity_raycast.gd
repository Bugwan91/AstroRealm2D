class_name VelocityRayCast
extends RayCast2D

signal body_on_way(body: RigidBody2D)

@export_range(0.1, 10.0) var estimated_time: float = 1.0

var _ship: ShipRigidBody

func _ready():
	_ship = owner as ShipRigidBody

func _physics_process(delta):
	target_position = (_ship.linear_velocity * estimated_time).rotated(-_ship.rotation)
	if is_colliding():
		body_on_way.emit(get_collider())
