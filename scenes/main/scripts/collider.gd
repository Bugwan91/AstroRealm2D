class_name Collider
extends Node2D

@export var radius := 64.0
@export_range(0, 1) var elasticity := 0.5

@onready var body: FloatingOriginBody = get_parent()

var _area: ColliderArea
var _shape: CapsuleShape2D

func _ready():
	_area = ColliderArea.new()
	add_child(_area)
	_shape = CapsuleShape2D.new()
	_shape.radius = radius
	_shape.height = radius * 2.0
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = _shape
	_area.add_child(collision_shape)

func _physics_process(delta):
	for area in _area.get_overlapping_areas():
		if area is ColliderArea:
			_on_collision(area.collider)

func _on_collision(other: Collider):
	var delta_p := other.body.position - body.position
	var delta_v := (other.body.relative_velocity - body.relative_velocity).project(delta_p)
	var overlapping := (radius + other.radius) - delta_p.length()
	body.move(-overlapping * 0.5 * delta_p.normalized())
	var impulse: Vector2 = ((1.0 + elasticity * other.elasticity) / (body.mass_inv + other.body.mass_inv)) * delta_v
	body.add_impulse(impulse)

