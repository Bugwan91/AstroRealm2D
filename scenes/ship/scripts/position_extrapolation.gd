class_name PositionExtrapolation
extends Node2D

@export var enabled := true

var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var smooth_position: Vector2:
	get:
		return owner.position + position.rotated(owner.rotation)

var smooth_rotation: float:
	get:
		return owner.rotation + rotation

var body: FloatingOriginBody

func _ready():
	process_priority = -999
	body = get_parent() as FloatingOriginBody

func _process(_delta):
	if not enabled: return
	var delta = Time.get_ticks_usec() * 0.000001
	rotation = body.angular_velocity * (delta - FloatingOrigin.last_physic_time)
	position = body.absolute_velocity.rotated(-body.rotation) * (delta - FloatingOrigin.last_physic_time)

func _physics_process(_delta):
	if not enabled: return
	position = Vector2.ZERO
	rotation = 0.0

