class_name ViewLayerBaker
extends SubViewport

@export var type: ViewBakerResource.TextureType
@export var background: Texture2D: set = _set_background

@onready var _views: Node2D = %views
@onready var _background: Sprite2D = %background
@onready var _hull: Sprite2D = %hull
@onready var _hull_ext: Sprite2D = %hull_ext
@onready var _cockpit: Sprite2D = %cockpit
@onready var _engines: Node2D = %engines

func _ready():
	_background.texture = background

func bake() -> Texture2D:
	if not is_node_ready(): await ready
	render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var texture = ImageTexture.new()
	return texture.create_from_image(get_viewport().get_texture().get_image())

func _set_background(texture: Texture2D):
	background = texture
	if not is_instance_valid(_background): return
	_background.texture = texture

func update(type: ShipBlueprint.Type, value: Resource):
	match  type:
		ShipBlueprint.Type.HULL: set_hull(value)
		ShipBlueprint.Type.HULL_EXT: set_hull_ext(value)
		ShipBlueprint.Type.COCKPIT: set_cockpit(value)
		ShipBlueprint.Type.ENGINE: set_engine(value)

func set_hull(resource: HullBakerResource):
	if resource == null: return # Hull is mandatory, can't be completely romoved
	# TODO: cockpit and engine should be made mandatory as well
	_hull.texture = resource.texture(type)
	_cockpit.position = resource.cockpit_slot
	_cockpit.position = resource.cockpit_slot
	_create_engines(resource.engine_slots, _clear_engines())


func set_hull_ext(resource: ViewBakerResource):
	if resource == null:
		_hull_ext.texture = null
	else:
		_hull_ext.texture = resource.texture(type)
		_views.move_child(_hull_ext, 2 if resource.ontop else 1)

func set_cockpit(resource: ViewBakerResource):
	_cockpit.texture = resource.texture(type) if resource != null else null

func set_engine(resource: ViewBakerResource):
	for engine in _engines.get_children() as Array[Sprite2D]:
		engine.texture = resource.texture(type) if resource != null else null

func _clear_engines() -> Texture2D:
	var texture: Texture2D
	if _engines.get_child_count() > 0:
		var engines = _engines.get_children()
		texture = engines[0].texture
		for engine in engines:
			_engines.remove_child(engine)
			engine.queue_free()
	return texture

func _create_engines(positions: Array[Vector2], texture: Texture2D):
	for engine_position in positions:
		var engine := Sprite2D.new()
		engine.position = engine_position
		engine.texture = texture
		_engines.add_child(engine)

