@tool
extends Sprite2D

@export_range(0, 1) var opacity := 0.5: set = update_opacity
@export var grid_offset: Vector2: set = update_offset
@export var grid_scale := 1.0: set = update_scale
@export var camera: Camera2D

var _inverted_scale: Vector2
var _start_scale: Vector2
var _start_grid_scale: float

func _ready():
	_start_scale = scale
	_start_grid_scale = grid_scale

func _process(_delta):
	position = camera.position
	scale = _start_scale / camera.zoom
	grid_offset = camera.position / (texture.get_size() * grid_scale)
	material.set("shader_parameter/scale", scale / grid_scale)

func update_opacity(value: float):
	if opacity == value: return
	opacity = value
	material.set("shader_parameter/opacity", opacity)

func update_offset(value: Vector2):
	if grid_offset == value: return
	grid_offset = value
	material.set("shader_parameter/offset", grid_offset)

func update_scale(value: float):
	if grid_scale == value: return
	grid_scale = value
	material.set("shader_parameter/scale", scale / grid_scale)
