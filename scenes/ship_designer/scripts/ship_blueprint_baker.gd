class_name ShipBlueprintBaker
extends Node
#TODO: Render viewports only on demand
signal updated(design: ShipTexturesRes)

@export var bake_on_updates := false
@export var blueprint: ShipBlueprint: set = _set_blueprint

@onready var polygon: ShipPolygonBaker = %Polygon
@onready var diffuse: ViewLayerBaker = %Diffuse
@onready var mask: ViewLayerBaker = %Mask
@onready var normal: ViewLayerBaker = %Normal
@onready var emission: ViewLayerBaker = %Emission
@onready var specular: ViewLayerBaker = %Specular
@onready var style: ShipStyleBaker = %Style

var design: ShipTexturesRes = ShipTexturesRes.new()
var _is_baking := false

func _ready():
	blueprint = ShipBlueprint.new()

func _on_blueprint_update(type: ShipBlueprint.Type, value: Resource):
	_update_blueprint_value(type, value)
	if bake_on_updates: bake()

func _update_blueprint_value(type: ShipBlueprint.Type, value: Resource):
	diffuse.update(type, value)
	mask.update(type, value)
	normal.update(type, value)
	emission.update(type, value)
	specular.update(type, value)
	if type == ShipBlueprint.Type.STYLE:
		style.style = value
	else:
		polygon.update(type, value)

func _set_blueprint(value: ShipBlueprint):
	blueprint = value
	blueprint.updated.connect(_on_blueprint_update)
	_update_blueprint_value(ShipBlueprint.Type.HULL, value.hull)
	_update_blueprint_value(ShipBlueprint.Type.HULL_EXT, value.hull_ext)
	_update_blueprint_value(ShipBlueprint.Type.COCKPIT, value.cockpit)
	_update_blueprint_value(ShipBlueprint.Type.ENGINE, value.engine)
	_update_blueprint_value(ShipBlueprint.Type.STYLE, value.style)

func bake() -> ShipTexturesRes:
	if _is_baking: return
	_is_baking = true
	design = await _bake_textures()
	_bake_polygon()
	updated.emit(design)
	_is_baking = false
	return design

func _bake_polygon():
	polygon.bake()
	design.polygon = polygon.polygon
	design.engines = polygon.engines
	design.thrusters = polygon.thrusters

func _bake_textures() -> ShipTexturesRes:
	design.diffuse = await _bake_diffuse()
	design.normal = await normal.bake()
	design.emision = await emission.bake()
	design.specular = await specular.bake()
	return design

func _bake_diffuse() -> Texture2D:
	style.texture = await diffuse.bake()
	style.mask = await mask.bake()
	return await style.bake()
