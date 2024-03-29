class_name Bullet
extends FloatingOriginKinetic

@export var group: String
@export var hit_effect_scene: PackedScene
@export var _color: Color
@export var glow := 3.0
@export_range(0, 5) var time_prediction := 2.0

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D
@onready var prediction_ray: RayCast2D = %PredictionRay
@onready var sprite: Sprite2D = %Sprite
@onready var light: Light2D = %Light
@onready var trail: TrailEffect = %Trail

var start_velocity: Vector2 = Vector2.ZERO

var impulse := 0.0
var bullet_speed := 0.0
var _damage := 10.0

func _ready():
	absolute_velocity = start_velocity + transform.x * bullet_speed

func _physics_process(delta: float):
	_update_ray(delta)
	_collide()

func update_material(color: Color):
	_color = color
	var color_hdr := _color * glow
	sprite.modulate = color_hdr
	trail.color = color_hdr
	light.color = _color

func start(lifetime: float, delta: float):
	timer.timeout.connect(queue_free)
	timer.start(lifetime)

func _update_ray(delta: float):
	ray.target_position.y = bullet_speed * delta
	prediction_ray.target_position.y = bullet_speed * time_prediction

func _collide(force: bool = false):
	if force: ray.force_raycast_update()
	if ray.is_colliding():
		_on_hit(ray.get_collider())

func _on_hit(target: TakingDamage):
	if not target is TakingDamage: return
	target = target as TakingDamage
	if target.check_group(group): return
	target.damage(_create_damage())
	var hit_effect := hit_effect_scene.instantiate() as BulletHitEffect
	hit_effect.position = ray.get_collision_point()
	hit_effect.absolute_velocity = start_velocity + transform.x * bullet_speed * 0.5
	hit_effect.color = _color
	MainState.main_scene.add_child(hit_effect)
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
