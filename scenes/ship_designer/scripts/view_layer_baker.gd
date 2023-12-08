@tool
class_name ViewLayerBaker
extends SubViewport

enum ItemType { HULL, HULL_EXT, COCKPIT, ENGINE }

@export var type: ViewBakerResource.TextureType
@export var background: Texture2D: set = _set_background

@onready var _views: Node2D = %views
@onready var _background: Sprite2D = %background
@onready var _hull: Sprite2D = %hull
@onready var _hull_ext: Sprite2D = %hull_ext
@onready var _cockpit: Sprite2D = %cockpit
@onready var _engines: Node2D = %engines

var _hull_poly := PackedVector2Array()
var _hull_ext_poly := PackedVector2Array()
var _cockpit_poly := PackedVector2Array()
var _engine_poly := PackedVector2Array()

func _ready():
	_background.texture = background

func bake() -> Texture2D:
	return get_viewport().get_texture()


func _set_background(texture: Texture2D):
	background = texture
	_background.texture = texture


func update(type: ItemType, resource: Resource):
	match type:
		ItemType.HULL: set_hull(resource)
		ItemType.HULL_EXT: set_hull_ext(resource)
		ItemType.COCKPIT: set_cockpit(resource)
		ItemType.ENGINE: set_engine(resource)


func set_hull(resource: HullBakerResource):
	if resource == null: return # Hull is mandatory, can't be completely romoved
	_hull_poly = resource.view.polygon.data
	_hull.texture = resource.view.texture(type)
	_cockpit.position = resource.cockpit_slot
	_cockpit.position = resource.cockpit_slot
	_create_engines(resource.engine_slots, _clear_engines())


func set_hull_ext(resource: ViewBakerResource):
	if resource == null:
		_hull_ext.texture = null
		_hull_ext_poly.clear()
	else:
		_hull_ext_poly = resource.polygon.data
		_hull_ext.texture = resource.texture(type)
		_views.move_child(_hull_ext, 2 if resource.ontop else 1)


func set_cockpit(resource: ViewBakerResource):
	if resource == null:
		_cockpit.texture = null
		_cockpit_poly.clear()
	else:
		_cockpit.texture = resource.texture(type)
		_cockpit_poly = resource.polygon.data


func set_engine(resource: ViewBakerResource):
	if resource == null:
		_engine_poly.clear()
	for engine in _engines.get_children() as Array[Sprite2D]:
		engine.texture = resource.texture(type) if resource != null else null


func bake_polygon() -> PackedVector2Array:
	var poly = Geometry2D.merge_polygons(_hull_poly, _hull_ext_poly)[0]
	poly = Geometry2D.merge_polygons(poly, _shift_polygon(_cockpit_poly, _cockpit.position))[0]
	for engine in _engines.get_children() as Array[Sprite2D]:
		poly = Geometry2D.merge_polygons(poly, _shift_polygon(_engine_poly, engine.position))[0]
	return poly


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


func _shift_polygon(polygon: PackedVector2Array, shift: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in polygon:
		points.append(point + shift)
	return points
