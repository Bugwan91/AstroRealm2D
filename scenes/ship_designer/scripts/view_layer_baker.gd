class_name ViewLayerBaker
extends SubViewport

const BASE_SIZE = Vector2(128.0, 128.0)

@export var type: ViewBakerResource.TextureType
@export var background: Texture2D: set = _set_background

# FIXME: The class variable "_views" is declared but never used in the class.
@onready var _views: Node2D = %views
@onready var _background: Sprite2D = %background
@onready var _hull: Sprite2D = %hull
@onready var _hull_ext: Sprite2D = %hull_ext

func _ready() -> void:
	_background.texture = background

func bake() -> Texture2D:
	if not is_node_ready(): await ready
	render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	return ImageTexture.create_from_image(get_viewport().get_texture().get_image())

func _set_background(texture: Texture2D) -> void:
	background = texture
	if not is_instance_valid(_background): return
	_background.texture = texture

func update(_type: ShipBlueprint.Type, value: Resource) -> void:
	match _type:
		ShipBlueprint.Type.HULL: set_hull(value)
		ShipBlueprint.Type.HULL_EXT: set_hull_ext(value)

func set_hull(resource: HullBakerResource) -> void:
	if resource == null: return # Hull is mandatory, can't be completely romoved
	_hull.texture = resource.texture(type)
	_hull.position = -resource.pivot_point
	_views.position = (BASE_SIZE / resource.scale) * 0.5
	size = BASE_SIZE / resource.scale

func set_hull_ext(resource: ViewBakerResource) -> void:
	if resource == null:
		_hull_ext.texture = null
	else:
		_hull_ext.texture = resource.texture(type)
		_hull_ext.position = -resource.pivot_point
