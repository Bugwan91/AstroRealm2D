class_name FloatingOriginBody
extends Node2D

signal got_hit(impulse: Vector2)

@export var mass: float
@export var inertia: float

@export var linear_velocity: Vector2:
	set(value):
		if self == FloatingOrigin.origin_body:
			FloatingOrigin.add_velocity(value - linear_velocity)
		else:
			linear_velocity = value

@export var angular_velocity: float

@onready var _mass_inv := 1.0 / mass
@onready var _inertia_inv := 1.0 / inertia

var acceleration: Vector2:
	get:
		return linear_velocity - last_velocity

var absolute_velocity: Vector2:
	get:
		return linear_velocity - FloatingOrigin.velocity

var absolute_position: Vector2:
	get:
		return position - FloatingOrigin.origin

var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var last_velocity: Vector2
var shift: Vector2

func _process(delta):
	shift = linear_velocity * delta
	position += shift
	rotation += angular_velocity * delta
	if self == FloatingOrigin.origin_body:
		shift = -FloatingOrigin.shift

func _physics_process(_delta):
	last_velocity = linear_velocity

func apply_impulse(impulse: Vector2):
	linear_velocity += impulse * _mass_inv
