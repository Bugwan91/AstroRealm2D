class_name FloatingOriginBody
extends FloatingOriginKinetic

signal got_hit(impulse: Vector2)

@export var mass: float
@export var inertia: float

@onready var mass_inv := 1.0 / mass
@onready var inertia_inv := 1.0 / inertia
@onready var _main_collider: TakingDamage = $TakingDamage

func add_impulse(impulse: Vector2):
	add_velocity(impulse * mass_inv)
