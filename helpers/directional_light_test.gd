extends DirectionalLight2D

var c := 0.0

func _process(delta: float) -> void:
	c += delta * 0.1
	height = .5 * sin(c) + .5
	MyDebug.info("Light", height)
