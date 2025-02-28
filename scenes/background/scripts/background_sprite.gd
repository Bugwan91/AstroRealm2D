class_name BackgroundSprite
extends Sprite2D

const UV_SIZE = 1.0 / 4096.0

@export var is_static: bool = false

var distance: float:
	set(value):
		distance = value
		_d = distance * UV_SIZE

var _vp_size: Vector2
var _sp_size: Vector2
var _zoom: float
var _d: float
var _position: Vector2

func _ready() -> void:
	if is_instance_valid(material):
		var u_mat := material.duplicate()
		material = u_mat
	CameraController.instance.updated.connect(camera_updated)
	camera_updated(Vector2.ZERO, 1.0)

func camera_updated(pos: Vector2, zoom: float):
	_vp_size = CameraController.instance.get_viewport_rect().size
	_sp_size = _vp_size / zoom
	_position = pos
	_zoom = zoom
	scale = _sp_size / texture.get_size()
	position = Vector2.ZERO
	shift()

func shift() -> void:
	if is_static: return
	var vp := _vp_size * UV_SIZE
	var _s := (_d * _zoom + 1.0) / (_d * _zoom + _zoom)
	material.set("shader_parameter/vp", vp * _s)
	material.set("shader_parameter/offset", _position * UV_SIZE / (_d + 1.0))
