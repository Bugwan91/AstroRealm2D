class_name Bullet
extends KineticBody

@export var group: String
@export var hit_effect_scene: PackedScene
@export var color: Color
@export var effective_lifetime: float = 1.0
@export var extra_lifetime: float = 0.5
@export_range(0.0, 10.0) var glow := 1.0
@export_range(0, 5) var time_prediction := 2.0

@onready var ray: RayCast2D = %RayCast2D
@onready var prediction_ray: RayCast2D = %PredictionRay
@onready var sprite: Sprite2D = %Sprite
@onready var light: Light2D = %Light
@onready var trail: TrailEffect = %Trail

var start_velocity: Vector2 = Vector2.ZERO
var origin: Node2D

var impulse := 0.0
var relative_speed := 0.0
var _damage := 10.0
var _base_velocity: Vector2
var _current_lifetime := 0.0
var _light_base_energy: float

func _ready():
	_base_velocity = transform.x * relative_speed
	linear_velocity = start_velocity + _base_velocity
	trail.velocity = _base_velocity
	ray.collision_mask = 3
	_light_base_energy = light.energy
	_update_material()
	#prediction_ray.collision_mask = 7

func _process(delta: float):
	super._process(delta)
	_handle_lifetime(delta)
	_update_ray(delta)
	_collide()

func _update_material(mult: float = 1.0):
	var color_hdr := color * glow * mult
	sprite.modulate = color_hdr
	trail.color = color_hdr
	light.color = color
	light.energy = _light_base_energy * mult

func _handle_lifetime(delta: float):
	_current_lifetime += delta
	if _current_lifetime > effective_lifetime:
		if _current_lifetime > (effective_lifetime + extra_lifetime):
			queue_free()
			return
		_update_material(1.0 - (_current_lifetime - effective_lifetime) / extra_lifetime)

func _update_ray(delta: float):
	ray.target_position.y = speed * delta
	prediction_ray.target_position.y = speed * time_prediction

func _collide(force: bool = false):
	if force: ray.force_raycast_update()
	if ray.is_colliding():
		_on_hit(ray.get_collider())

func _on_hit(target: TakingDamage):
	if not target is TakingDamage: return
	target = target as TakingDamage
	if target.parent == origin: return
	#if target.check_group(group): return
	var hit_effect := hit_effect_scene.instantiate() as BulletHitEffect
	hit_effect.color = color
	target.damage(_create_damage(), hit_effect)
	queue_free()

func _create_damage() -> Damage:
	var damage := Damage.new()
	damage.amount = _damage
	damage.position = ray.get_collision_point()
	damage.impulse = transform.x * impulse
	return damage

func _predict_hit():
	if not prediction_ray.is_colliding(): return
	pass
