extends RigidBody2D

@export var radial_force: float = 1
@onready var ship = %Ship
@onready var gun = $Gun as Gun

func _ready():
	#gun.start_fire()
	pass

func _physics_process(_delta):
	apply_central_force(linear_velocity.normalized().rotated(3.14 / 2.0) * radial_force)

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		ship.set_target(self)
