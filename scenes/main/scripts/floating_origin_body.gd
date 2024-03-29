class_name FloatingOriginBody
extends Node2D

signal got_hit(impulse: Vector2)

@export var mass: float
@export var inertia: float

var _linear_velocity: Vector2
## Do not update velocity directly.
## Use add_velocity() method instead for correct acceleration handling
@export var linear_velocity: Vector2:
	set(value):
		if is_origin():
			FloatingOrigin.velocity = value
		else:
			_linear_velocity = value
	get:
		return FloatingOrigin.velocity if is_origin() else _linear_velocity

@export var angular_velocity: float

@onready var _mass_inv := 1.0 / mass
@onready var _inertia_inv := 1.0 / inertia

var acceleration: Vector2
var _acceleration_next_tick: Vector2

var absolute_velocity: Vector2:
	get:
		return linear_velocity if is_origin() else linear_velocity + FloatingOrigin.velocity

var absolute_position: Vector2:
	get:
		return position - FloatingOrigin.origin

var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var shift: Vector2

func _process(delta):
	shift = linear_velocity * delta
	if not is_origin():
		position += shift
	rotation += angular_velocity * delta

func _physics_process(_delta):
	acceleration = _acceleration_next_tick
	linear_velocity += acceleration
	_acceleration_next_tick = Vector2.ZERO

func add_velocity(delta_v: Vector2):
	_acceleration_next_tick += delta_v

func add_impulse(impulse: Vector2):
	add_velocity(impulse * _mass_inv)

func is_origin() -> bool:
	return self == FloatingOrigin.origin_body
