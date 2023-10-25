extends Sprite2D

@export_range(0, 1) var base_opacity := 0.5
@export var grid_offset: Vector2
@export var grid_scale := 1.0
@export var speed_limit := 10000.0
@export var camera: Camera2D
@export var target: ShipRigidBody

@onready var subgrid = %Subgrid

var opacity: float
var _inverted_scale: Vector2
var _start_scale: Vector2
var _start_grid_scale: float

func _ready():
	_start_scale = scale
	_start_grid_scale = grid_scale
	update_opacity(base_opacity)
	update_scale(grid_scale)
	update_offset(grid_offset)

func _process(_delta):
	position = target.extrapolator.global_position
	scale = _start_scale / camera.zoom
	update_offset((position + FloatingOrigin.origin) / (texture.get_size() * grid_scale))
	update_scale(grid_scale)
	update_opacity(base_opacity * clamp((speed_limit - target.real_velocity.length()) / speed_limit, 0, 1))

func update_opacity(value: float = 0.0):
	opacity = value
	material.set("shader_parameter/opacity", opacity)
	subgrid.material.set("shader_parameter/opacity", opacity * 0.5)

func update_offset(value: Vector2 = Vector2.ZERO):
	grid_offset = value
	material.set("shader_parameter/offset", grid_offset)
	subgrid.material.set("shader_parameter/offset", grid_offset * 5)

func update_scale(value: float = 0.0):
	grid_scale = value
	material.set("shader_parameter/scale", scale / grid_scale)
	subgrid.material.set("shader_parameter/scale", 5 * scale / grid_scale)
