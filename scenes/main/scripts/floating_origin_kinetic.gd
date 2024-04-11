class_name FloatingOriginKinetic
extends Node2D

var _velocity: Vector2
## Do not update velocity directly.
## Use add_velocity() method instead for correct acceleration handling
@export var absolute_velocity: Vector2:
	set(value):
		if is_origin():
			FloatingOrigin.velocity = value
		else:
			_velocity = value
		speed = value.length()
	get:
		return FloatingOrigin.velocity if is_origin() else _velocity

@export var angular_velocity: float

var acceleration: Vector2
var _acceleration_next_tick: Vector2

var speed: float

var relative_speed: float:
	get:
		return relative_velocity.length()

var relative_velocity: Vector2:
	get:
		return Vector2.ZERO if is_origin() else absolute_velocity - FloatingOrigin.velocity

var absolute_position: Vector2:
	get:
		return position - FloatingOrigin.origin

var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var shift: Vector2

func _ready():
	process_priority = -1

func _process(delta: float):
	shift = _velocity * delta
	if not is_origin():
		position += shift
	rotation += angular_velocity * delta

func _physics_process(_delta: float):
	acceleration = _acceleration_next_tick
	absolute_velocity += acceleration
	_acceleration_next_tick = Vector2.ZERO

func add_velocity(delta_v: Vector2):
	_acceleration_next_tick += delta_v

func is_origin() -> bool:
	return self == FloatingOrigin.origin_body

func move(delta: Vector2):
	if is_origin():
		FloatingOrigin.origin += delta
	else:
		position += delta
	
