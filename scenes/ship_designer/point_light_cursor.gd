extends PointLight2D

func _process(delta: float) -> void:
	var h := color.h;
	h += delta * 0.2;
	if h > 1.0:
		h = 0;
	color = Color.from_hsv(h, color.s, color.v, color.a);
	position = get_global_mouse_position()
