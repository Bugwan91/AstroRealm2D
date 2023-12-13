class_name ShipStyleBaker
extends SubViewport

@export var texture: Texture2D: set = _set_texture
@export var style: Texture2D: set = _set_style
@export var mask: Texture2D: set = _set_mask

@onready var _view: Sprite2D = %View

func _ready():
	_view.material = _view.material.duplicate()
	get_viewport()

func bake() -> Texture2D:
	return get_viewport().get_texture()

func _set_texture(value: Texture2D):
	texture = value
	if not is_instance_valid(_view): return
	_view.texture = texture

func _set_mask(value: Texture2D):
	mask = value
	if not is_instance_valid(_view): return
	_view.material.set("shader_parameter/mask_texture", mask)

func _set_style(value: Texture2D):
	style = value
	if not is_instance_valid(_view): return
	_view.material.set("shader_parameter/style_texture", style)

