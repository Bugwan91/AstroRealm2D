class_name BackgroundSprite
extends Sprite2D

const UV_SIZE = 4096.0

var base_shift_scale: float:
	set(value):
		base_shift_scale = value
		resize()
var shift_scale: float 
var _vp_to_uv_size: Vector2

func _ready():
	get_viewport().size_changed.connect(resize)
	resize()

func shift(shift_vector: Vector2, zoom: Vector2):
	material.set("shader_parameter/scale", shift_scale)
	material.set("shader_parameter/vp_size", _vp_to_uv_size)
	material.set("shader_parameter/offset", shift_vector)
	material.set("shader_parameter/zoom", zoom)

func resize():
	var vp_size := Vector2(get_viewport().size)
	_vp_to_uv_size = vp_size / UV_SIZE
	scale = Vector2.ONE * vp_size / texture.get_size()
	position = vp_size * 0.5
	shift_scale = base_shift_scale / UV_SIZE
