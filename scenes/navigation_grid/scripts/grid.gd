class_name NavGrid
extends Sprite2D

const SUBGRID_SCALE := 5.0

@export_range(0, 1) var base_opacity := 0.5
@export var grid_offset: Vector2
@export var grid_scale := 1.0
@export var speed_limit := 10000.0

@onready var _subgrid: Sprite2D = %Subgrid

var camera: Camera2D
var ignore_floating := true
var target: Spaceship
var opacity: float

var _start_scale: Vector2
var _start_grid_scale: float

func _ready():
	process_priority = -100
	MainState.player_ship_updated.connect(_on_update_player_ship)
	camera = get_viewport().get_camera_2d()
	_start_scale = scale
	_start_grid_scale = grid_scale
	update_opacity(base_opacity)
	update_scale(grid_scale)
	update_offset(grid_offset)

func _process(_delta):
	if not is_instance_valid(target):
		update_opacity(0.0)
		return
	scale = _start_scale / camera.zoom
	update_offset((-FloatingOrigin.origin) / (texture.get_size() * grid_scale))
	update_scale(grid_scale)
	update_opacity(base_opacity * clamp((speed_limit - target.speed) / speed_limit, 0, 1))

func update_opacity(value: float = 0.0):
	opacity = value
	material.set("shader_parameter/opacity", opacity)
	_subgrid.material.set("shader_parameter/opacity", opacity * SUBGRID_SCALE / scale.x)

func update_offset(value: Vector2 = Vector2.ZERO):
	grid_offset = value
	material.set("shader_parameter/offset", grid_offset)
	_subgrid.material.set("shader_parameter/offset", grid_offset * 5)

func update_scale(value: float = 0.0):
	grid_scale = value
	material.set("shader_parameter/scale", scale / grid_scale)
	_subgrid.material.set("shader_parameter/scale", SUBGRID_SCALE * scale / grid_scale)

func _on_update_player_ship(player_ship: Spaceship):
	target = player_ship
