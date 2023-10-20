extends RigidBody2D

@export var radial_force: float = 1
@export var is_firing := false
@export var rotate_towards_player := false

@onready var ship = %Ship
@onready var gun = $Gun as Gun
@onready var gun_2 = $Gun2 as Gun
@onready var extrapolator = $PositionExtrapolation
@onready var player = %Ship

func _ready():
	if is_firing:
		gun.start_fire()
		gun_2.start_fire()

func _physics_process(_delta):
	apply_central_force(linear_velocity.normalized().rotated(3.14 / 2.0) * radial_force)

func _integrate_forces(state):
	if rotate_towards_player:
		var angle: float = (player.position - position).angle()
		state.transform = Transform2D(angle, state.transform.origin)

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		ship.set_target(self)
