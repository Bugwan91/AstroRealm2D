extends GPUParticles2D

var _velocity_curve: CurveXYZTexture

func _ready():
	_velocity_curve = process_material.directional_velocity_curve
	_velocity_curve.curve_x.add_point(Vector2(1,0))
	_velocity_curve.curve_x.min_value = -1
	_velocity_curve.curve_y.add_point(Vector2(1,0))
	_velocity_curve.curve_y.min_value = -1

func _process(_delta):
	var speed := FloatingOrigin.speed
	process_material.directional_velocity_min = speed
	process_material.directional_velocity_max = speed
	_velocity_curve.curve_x.set_point_value(0, -FloatingOrigin.velocity.x / speed)
	_velocity_curve.curve_y.set_point_value(0, -FloatingOrigin.velocity.y / speed)

