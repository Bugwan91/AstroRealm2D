class_name Bullet
extends FloatingOriginBody

@export var group: String
@export var hit_effect_scene: PackedScene
@export var _color: Color
@export var glow := 3.0
@export_range(0, 5) var time_prediction := 2.0

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D
@onready var long_ray: RayCast2D = %LongRay
@onready var sprite: Sprite2D = %Sprite
@onready var light: Light2D = %Light
@onready var trail: TrailEffect = %Trail

var start_velocity: Vector2 = Vector2.ZERO

var impulse := 0.0
var speed := 0.0
var _damage := 10.0

func _ready():
	linear_velocity = -FloatingOrigin.velocity + start_velocity + transform.x * speed

func _physics_process(delta):
	ray.target_position.y = speed * delta
	long_ray.target_position.y = speed * time_prediction
	_collide()

func update_material(color: Color):
	_color = color
	var color_hdr := _color * glow
	sprite.modulate = color_hdr
	trail.color = color_hdr
	light.color = _color

func start(lifetime: float):
	timer.timeout.connect(queue_free)
	timer.start(lifetime)

func _collide():
	if ray.is_colliding():
		_on_hit(ray.get_collider())

func _on_hit(target):
	if not is_instance_valid(target): return
	# TODO: update to hitting TakingDamage directly
	var damageTaker = target.get_node("TakingDamage") as TakingDamage
	if is_instance_valid(damageTaker):
		if damageTaker.check_group(group):
			return
		damageTaker.damage(_create_damage())
	var hit_effect = hit_effect_scene.instantiate() as BulletHitEffect
	hit_effect.position = ray.get_collision_point()
	hit_effect.linear_velocity = target.absolute_velocity
	hit_effect.color = _color
	MainState.main_scene.add_child(hit_effect)
	queue_free()

func _create_damage() -> Damage:
	var damage = Damage.new()
	damage.amount = _damage
	damage.position = ray.get_collision_point()
	damage.impulse = transform.x * impulse
	return damage

func _predict_hit():
	if not long_ray.is_colliding(): return
	pass
