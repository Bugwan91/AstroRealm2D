class_name NavGrid
extends Sprite2D

const SUBGRID_SCALE := 5.0

@export_range(0, 1) var base_opacity := 0.5
@export var grid_offset: Vector2
@export var grid_scale := 1.0
@export var speed_limit := 3000.0
@export var offset_shift: Vector2

@onready var _subgrid: Sprite2D = %Subgrid

var camera: Camera2D
var target: Spaceship
var opacity: float

var _start_scale: Vector2
var _start_grid_scale: float

func _ready() -> void:
	PlayerManager.instance.ship_spawned.connect(_on_player_spawn)
	PlayerManager.instance.ship_destroyed.connect(_on_player_destroyed)
	camera = get_viewport().get_camera_2d()
	_start_scale = scale
	_start_grid_scale = grid_scale
	update_opacity(base_opacity)
	update_scale(grid_scale)
	update_offset(grid_offset)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		update_opacity(0.0)
		return
	position = target.position
	scale = _start_scale / camera.zoom
	update_offset((-position + offset_shift) / (texture.get_size() * grid_scale))
	update_scale(grid_scale)
	update_opacity(base_opacity * clamp((speed_limit - target.linear_velocity.length()) / speed_limit, 0, 1))

func update_opacity(value: float = 0.0) -> void:
	opacity = value
	material.set("shader_parameter/opacity", opacity)
	_subgrid.material.set("shader_parameter/opacity", opacity * SUBGRID_SCALE / scale.x)

func update_offset(value: Vector2 = Vector2.ZERO) -> void:
	grid_offset = value
	material.set("shader_parameter/offset", grid_offset)
	_subgrid.material.set("shader_parameter/offset", grid_offset * 5)

func update_scale(value: float = 0.0) -> void:
	grid_scale = value
	material.set("shader_parameter/scale", scale / grid_scale)
	_subgrid.material.set("shader_parameter/scale", SUBGRID_SCALE * scale / grid_scale)

func _on_player_spawn(player_ship: Spaceship) -> void:
	target = player_ship
	visible = true

func _on_player_destroyed() -> void:
	target = null
	visible = false
