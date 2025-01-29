class_name ShipStyleBaker
extends SubViewport

@export var texture: Texture2D: set = _set_texture
@export var style: Texture2D: set = _set_style
@export var mask: Texture2D: set = _set_mask

@onready var _view: Sprite2D = %View

func _ready() -> void:
	_view.material = _view.material.duplicate()
	get_viewport()

func bake() -> Texture2D:
	if not is_node_ready(): await ready
	render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	return ImageTexture.create_from_image(get_viewport().get_texture().get_image())

func _set_texture(value: Texture2D) -> void:
	texture = value
	if not is_instance_valid(_view): return
	_view.texture = texture

func _set_mask(value: Texture2D) -> void:
	mask = value
	if not is_instance_valid(_view): return
	_view.material.set("shader_parameter/mask_texture", mask)

func _set_style(value: Texture2D) -> void:
	style = value
	if not is_instance_valid(_view): return
	_view.material.set("shader_parameter/style_texture", style)
