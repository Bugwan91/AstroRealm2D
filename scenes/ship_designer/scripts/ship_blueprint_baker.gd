class_name ShipBlueprintBaker
extends Node

signal updated(design: ShipTexturesRes)

@export var blueprint: ShipBlueprint:
	set(value):
		blueprint = value
		blueprint.updated.connect(_on_blueprint_update)

@onready var polygon: ShipPolygonBaker = %Polygon
@onready var diffuse: ViewLayerBaker = %Diffuse
@onready var mask: ViewLayerBaker = %Mask
@onready var normal: ViewLayerBaker = %Normal
@onready var emission: ViewLayerBaker = %Emission
@onready var specular: ViewLayerBaker = %Specular
@onready var style: ShipStyleBaker = %Style

var design: ShipTexturesRes = ShipTexturesRes.new()

func _ready():
	blueprint = ShipBlueprint.new()

func _on_blueprint_update(type: ShipBlueprint.Type, value: Resource):
	diffuse.update(type, value)
	mask.update(type, value)
	normal.update(type, value)
	emission.update(type, value)
	specular.update(type, value)
	if type == ShipBlueprint.Type.STYLE:
		style.style = value
	else:
		polygon.update(type, value)
	_bake_textures()
	_bake_polygon()
	updated.emit(design)

func _bake_polygon():
	design.polygon = polygon.merge_polygons()
	design.engines = polygon.engines
	design.thrusters = polygon.thrusters

func _bake_textures() -> ShipTexturesRes:
	design.diffuse = _bake_diffuse()
	design.normal = normal.bake()
	design.emision = emission.bake()
	design.specular = specular.bake()
	return design

func _bake_diffuse() -> Texture2D:
	style.texture = diffuse.bake()
	style.mask = mask.bake()
	return style.bake()
