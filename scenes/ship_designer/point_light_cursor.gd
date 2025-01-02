extends PointLight2D

func _process(delta: float) -> void:
	position = get_global_mouse_position()
