class_name FloatingOriginBody
extends FloatingOriginKinetic

signal got_hit(impulse: Vector2)

@export var mass: float
@export var inertia: float

@onready var _mass_inv := 1.0 / mass
@onready var _inertia_inv := 1.0 / inertia

func add_impulse(impulse: Vector2):
	add_velocity(impulse * _mass_inv)
