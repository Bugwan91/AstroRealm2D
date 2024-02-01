class_name ShipCollisionDetector
extends Area2D

signal potential_collision(direction: Vector2)
signal close_collision(direction: Vector2)

@export var enabled := true:
	set(value):
		enabled = value
		if not value:
			_bodies.clear()
		monitoring = value
		
@export_range(0, 1) var dot_threshold: float = 0.1
@export_range(0, 10000) var speed_threshold: float = 100.0:
	set(value):
		speed_threshold = value
		_speed_threshold_sq = value ** 2
@export_range(0, 1000) var critical_distance: float = 500.0

var _bodies: Array[FloatingOriginRigidBody]
var _ship: ShipRigidBody
var _speed_threshold_sq: float

func _ready():
	_ship = owner as ShipRigidBody

func _physics_process(_delta):
	_update_potential_collision()

func _on_body_entered(body: RigidBody2D):
	if body == owner: return
	_bodies.append(body as FloatingOriginRigidBody)

func _on_body_exited(body: RigidBody2D):
	_bodies.erase(body as FloatingOriginRigidBody)

func _update_potential_collision():
	if not monitoring: return
	for target in _bodies:
		var d := (target.position - _ship.position)
		var d_len := d.length()
		if d_len < critical_distance:
			close_collision.emit(d / d_len)
			return
		var v := (target.linear_velocity - _ship.linear_velocity)
		var v_len_sq = v.length_squared()
		if v_len_sq < _speed_threshold_sq: return
		var d_n := d / d_len
		var dot := d_n.dot(v / sqrt(v_len_sq))
		if dot < (-1.0 + dot_threshold):
			potential_collision.emit(d_n)
