@tool
extends Node

@export var filename: String = "image"
@export var style: Texture2D: set = _set_style
@export var base_specular: Texture2D: set = _set_base_specular
@export var hull: HullBakerResource: set = _set_hull
@export var hull_ext: ViewBakerResource: set = _set_hull_ext
@export var cockpit: ViewBakerResource: set = _set_cockpit
@export var engine: ViewBakerResource: set = _set_engine

@onready var _base_baker: ViewLayerBaker = %BaseBaker
@onready var _emission_baker: ViewLayerBaker = %EmissionBaker
@onready var _mask_baker: ViewLayerBaker = %MaskBaker
@onready var _normal_baker: ViewLayerBaker = %NormalBaker
@onready var _specular_baker: ViewLayerBaker = %SpecularBaker
@onready var _stylizator_baker: SubViewport = %Stylizator

var _bakers: Array[ViewLayerBaker]

@onready var _stylizator_view: Sprite2D = %StylizatorView

func _ready():
	_init_bakers()
	_update_sub_bakers(ViewLayerBaker.ItemType.HULL, hull)
	_update_sub_bakers(ViewLayerBaker.ItemType.HULL_EXT, hull_ext)
	_update_sub_bakers(ViewLayerBaker.ItemType.COCKPIT, cockpit)
	_update_sub_bakers(ViewLayerBaker.ItemType.ENGINE, engine)
	_update_style()

func bake():
	_bake_textures()
	var res = ShipTexturesRes.new()
	var tex = ImageTexture.new()
	var img = Image
	res.diffuse = tex.create_from_image(img.load_from_file("res://resources/ships/views/images/" + filename + ".png"))
	res.normal = tex.create_from_image(img.load_from_file("res://resources/ships/views/images/" + filename + "_normal.png"))
	res.emision = tex.create_from_image(img.load_from_file("res://resources/ships/views/images/" + filename + "_emission.png"))
	res.specular = tex.create_from_image(img.load_from_file("res://resources/ships/views/images/" + filename + "_specular.png"))
	res.polygon = _rotate_polygon(_base_baker.bake_polygon(), 0.5 * PI)
	res.thrusters = hull.thrusters.rotated(0.5 * PI)
	res.engines = _rotate_polygon(hull.get_engines_points(), 0.5 * PI)
	ResourceSaver.save(res, "res://resources/ships/views/" + filename + ".tres")

func _bake_textures():
	_stylizator_baker.get_viewport().get_texture().get_image().save_png("res://resources/ships/views/images/" + filename + ".png")
	_normal_baker.bake().get_image().save_png("res://resources/ships/views/images/" + filename + "_normal.png")
	_emission_baker.bake().get_image().save_png("res://resources/ships/views/images/" + filename + "_emission.png")
	_specular_baker.bake().get_image().save_png("res://resources/ships/views/images/" + filename + "_specular.png")

func _get_tool_buttons() -> Array:
	return [bake]

func _set_style(texture: Texture2D):
	style = texture
	_update_style()

func _init_bakers():
	_bakers.clear()
	_bakers.append(_base_baker)
	_bakers.append(_mask_baker)
	_bakers.append(_normal_baker)
	_bakers.append(_emission_baker)
	_bakers.append(_specular_baker)

func _update_style():
	_stylizator_view.texture = _base_baker.bake()
	_stylizator_view.material.set("shader_parameter/mask_texture", _mask_baker.bake())
	_stylizator_view.material.set("shader_parameter/style_texture", style)

func _set_base_specular(texture: Texture2D):
	base_specular = texture
	_specular_baker.background = base_specular

func _set_hull(resource: HullBakerResource):
	hull = resource
	_update_sub_bakers(ViewLayerBaker.ItemType.HULL, hull)

func _set_hull_ext(resource: ViewBakerResource):
	hull_ext = resource
	_update_sub_bakers(ViewLayerBaker.ItemType.HULL_EXT, hull_ext)

func _set_cockpit(resource: ViewBakerResource):
	cockpit = resource
	_update_sub_bakers(ViewLayerBaker.ItemType.COCKPIT, cockpit)

func _set_engine(resource: ViewBakerResource):
	engine = resource
	_update_sub_bakers(ViewLayerBaker.ItemType.ENGINE, engine)

func _update_sub_bakers(type: ViewLayerBaker.ItemType, resource):
	for baker in _bakers:
		baker.update(type, resource)

func _rotate_polygon(polygon: PackedVector2Array, rotation: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in polygon:
		points.append(point.rotated(rotation))
	return points
