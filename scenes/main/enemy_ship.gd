extends RigidBody2D

@export var radial_force: float = 1
@export var is_firing := false
@export var rotate_towards_player := false
@export var players: Array[ShipRigidBody]

@onready var gun = $Gun as Gun

@onready var extrapolator = $PositionExtrapolation

func _ready():
	if is_firing:
		gun.start_fire()


func _physics_process(_delta):
	apply_central_force(linear_velocity.normalized().rotated(3.14 / 2.0) * radial_force)


func _integrate_forces(state):
	if rotate_towards_player:
		var angle: float = (players[0].position - position).angle()
		state.transform = Transform2D(angle, state.transform.origin)


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		for player in players:
			player.set_target(self)
