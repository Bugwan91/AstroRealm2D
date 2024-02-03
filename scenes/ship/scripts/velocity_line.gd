class_name VelocityLine
extends Area2D

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

var _ray := SegmentShape2D.new()

func _ready():
	_ray.b = Vector2.ZERO
	_collision_shape.shape = _ray

func update(end: float):
	_ray.b.x = end
