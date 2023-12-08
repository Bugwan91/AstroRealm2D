class_name BackgroundSprite
extends Sprite2D

const UV_SIZE = 1.0 / 4096.0

@export var is_static: bool = false

var distance: float:
	set(value):
		distance = value
		_d = distance * UV_SIZE


var _vp_size: Vector2
var _d: float
var _vp_uv: Vector2

func _ready():
	if is_instance_valid(material):
		var u_mat = material.duplicate()
		material = u_mat
	get_viewport().size_changed.connect(resize)
	resize()

func shift(shift_vector: Vector2, zoom: Vector2):
	if is_static: return
	var z := zoom.x
	var vp := _vp_size * UV_SIZE
	var _s := (_d * z + 1) / (_d * z + z)
	material.set("shader_parameter/vp", vp * _s)
	material.set("shader_parameter/offset", shift_vector * UV_SIZE / (_d + 1.0))

func resize():
	_vp_size = Vector2(get_viewport().size)
	scale = _vp_size / texture.get_size()
	position = _vp_size * 0.5
