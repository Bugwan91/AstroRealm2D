class_name ShipBlueprintBaker
extends Control
#TODO: Render viewports only on demand
signal updated(design: ShipDesignData)

@export var bake_on_updates := false
@export var blueprint: ShipBlueprint: set = _set_blueprint
@export var debug_visible := false:
	set(value):
		debug_visible = value
		visible = debug_visible

@onready var polygon: ShipPolygonBaker = %Polygon
@onready var diffuse: ViewLayerBaker = %Diffuse
@onready var normal: ViewLayerBaker = %Normal
@onready var mask: ViewLayerBaker = %Mask
@onready var emission: ViewLayerBaker = %Emission
@onready var heat: ViewLayerBaker = %Heat
@onready var style: ShipStyleBaker = %Style

var design: ShipDesignData = ShipDesignData.new()
var _is_baking := false

func _ready():
	blueprint = ShipBlueprint.new()
	visible = debug_visible

func _on_blueprint_update(type: ShipBlueprint.Type, value: Resource):
	_update_blueprint_value(type, value)
	if bake_on_updates: bake()

func _update_blueprint_value(type: ShipBlueprint.Type, value: Resource):
	diffuse.update(type, value)
	normal.update(type, value)
	mask.update(type, value)
	emission.update(type, value)
	heat.update(type, value)
	if type == ShipBlueprint.Type.STYLE:
		style.style = value
	else:
		polygon.update(type, value)

func _set_blueprint(value: ShipBlueprint):
	blueprint = value
	blueprint.updated.connect(_on_blueprint_update)
	_update_blueprint_value(ShipBlueprint.Type.HULL, value.hull)
	_update_blueprint_value(ShipBlueprint.Type.HULL_EXT, value.hull_ext)
	_update_blueprint_value(ShipBlueprint.Type.ENGINE, value.engine)
	_update_blueprint_value(ShipBlueprint.Type.STYLE, value.style)

func bake() -> ShipDesignData:
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
	design.weapon_slots = polygon.weapons

func _bake_textures() -> ShipDesignData:
	design.diffuse = await _bake_diffuse()
	design.normal = await normal.bake()
	design.emision = await emission.bake()
	design.heat = await heat.bake()
	return design

func _bake_diffuse() -> Texture2D:
	style.texture = await diffuse.bake()
	design.mask = await mask.bake()
	style.mask = design.mask
	return await style.bake()
