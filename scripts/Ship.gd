extends RigidBody2D

@export var engine_thrust: int
@export var spin_thrust: int

@export var flame_sprite: AnimatedSprite2D

var thrust = Vector2()
var rotation_dir = 0
var screensize

func _ready():
	screensize = get_viewport().get_visible_rect().size

func get_inputs():
	if Input.is_action_pressed("Throtle"):
		thrust = Vector2(engine_thrust, 0)
	else:
		thrust = Vector2()
	if Input.is_action_pressed("Right"):
		rotation_dir = 1
	elif Input.is_action_pressed("Left"):
		rotation_dir = -1
	else:
		rotation_dir = 0

func _process(delta):
	get_inputs()
	if thrust.length() == 0:
		flame_sprite.hide()
	else:
		flame_sprite.show()
	

func _physics_process(delta):
	apply_central_force(thrust.rotated(rotation))
	apply_torque(rotation_dir * spin_thrust)


