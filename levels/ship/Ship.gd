extends RigidBody2D

class_name Ship

@export var engine_thrust: int
@export var strafe_thrust: int
@export var spin_thrust: int

@onready var flame_sprite = $Flame

var thrust = Vector2()
var rotation_dir = 0
var screensize
var pointer_position

var _thrust_input: int = 0
var _strafe_input: int = 0

func set_thrust(value):
	pass

func set_strafe(value):
	pass

func set_spin(value):
	pass

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

func _input(event):
	if event is InputEventMouseMotion:
		pointer_position = Vector2(event.position.x / screensize.x, event.position.y / screensize.y)
		#print(pointer_position)

func _process(delta):
	get_inputs()
	if thrust.length() == 0:
		flame_sprite.hide()
	else:
		flame_sprite.show()
	

func _physics_process(delta):
	apply_central_force(thrust.rotated(rotation))
	apply_torque(rotation_dir * spin_thrust)


