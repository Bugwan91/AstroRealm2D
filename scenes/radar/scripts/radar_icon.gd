class_name RadarIcon
extends Sprite2D

const RADAR_PADDING := 0.98

@export var config: RadarIconConfig

static func create(conf: RadarIconConfig) -> RadarIcon:
	var icon := RadarIcon.new()
	icon._setup(conf)
	return icon

func _init_tecture() -> void:
	texture = config.texture
	modulate = config.color
	modulate.a = 0.2
	_recalculate_scale()

func _setup(conf: RadarIconConfig) -> void:
	config = conf.duplicate() if conf.unique else conf
	_init_tecture()
	visible = false

func update(pos: Vector2, rot: float, view_r: float, view_scale: float, relative_scale: float = 1.0) -> void:
	position = RADAR_PADDING * pos * view_scale
	if config.free_rotation: rotation = rot
	if config.use_real_size:
		_recalculate_scale(view_scale)
	else:
		_recalculate_scale(relative_scale)
	visible = true

func _recalculate_scale(v_scale: float = 1.0) -> void:
	scale = v_scale * _icon_scale() * Vector2(1.0, config.aspect)

func _icon_scale() -> float:
	return config.scale * (config.base_size / config.texture.get_width())

func setup_scale(value: float) -> void:
	config.scale = value
	_recalculate_scale()
