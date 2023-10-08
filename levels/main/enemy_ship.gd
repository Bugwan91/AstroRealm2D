extends RigidBody2D

@export var radial_force: float = 1

func _physics_process(delta):
	apply_central_force(linear_velocity.normalized().rotated(3.14 / 2.0) * radial_force)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Clicked!")
