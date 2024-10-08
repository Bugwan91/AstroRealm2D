class_name CollisionDetector
extends Node2D

const SPEED_THRESHOLD := 2.0
const ANGLE := 1.57079633 # 90 deg

signal predicted_collision(escape_direction: Vector2)

@export var enabled := true:
	set(value):
		enabled = value
		predicted_position.monitoring = value
		ray_left.enabled = value
		ray_right.enabled = value

@export_range(0.1, 10.0) var delta_time: float = 0.5

@export var ignored_objects: Array[CollisionObject2D]

@onready var ray_base: Node2D = %RayBase
@onready var line_left: VelocityLine = %VelocityLineLeft
@onready var line_right: VelocityLine = %VelocityLineRight
@onready var predicted_position: PredictedPositionArea = %PredictedPosition
@onready var predicted_position_close: PredictedPositionArea = %PredictedClosePosition
@onready var ray_left: VelocityRayCast = %RayLeft
@onready var ray_right: VelocityRayCast = %RayRight

var _ship: Spaceship
var _speed: float

func _ready():
	_ship = owner as Spaceship
	predicted_position_close.radius = 100.0
	exclude(predicted_position_close)
	exclude(predicted_position)
	exclude(line_left)
	exclude(line_right)
	for object in ignored_objects:
		exclude(object)

func exclude(object: CollisionObject2D):
	ray_left.add_exception(object)
	ray_right.add_exception(object)

func _physics_process(_delta):
	_speed = _ship.speed
	_check_collisions()
	_update_predicted_position()

func _check_collisions():
	if not enabled: return
	var collision_direction := predicted_position.check_potential_collision()
	if not collision_direction.is_zero_approx():
		predicted_collision.emit((-collision_direction).rotated(-_ship.rotation))
		_enable_rays(false)
		return
	_enable_rays()
	if _speed < SPEED_THRESHOLD: return
	var left := ray_left.is_colliding()
	var right := ray_right.is_colliding()
	if left and right:
		var d := -_ship.absolute_velocity.rotated(-_ship.rotation + 0.5).normalized()
		predicted_collision.emit(d)
	elif left:
		var d := _ship.absolute_velocity.rotated(-_ship.rotation + ANGLE).normalized()
		predicted_collision.emit(d)
	elif right:
		var d := _ship.absolute_velocity.rotated(-_ship.rotation - ANGLE).normalized()
		predicted_collision.emit(d)

func _update_predicted_position():
	ray_base.global_rotation = _ship.absolute_velocity.angle()
	var end := delta_time * _speed
	line_left.update(end)
	line_right.update(end)
	predicted_position.update(end)
	predicted_position_close.update(end)
	ray_left.update(end)
	ray_right.update(end)

func _enable_rays(is_enabled: bool = true):
	ray_left.enabled = is_enabled
	ray_right.enabled = is_enabled

