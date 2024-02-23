@tool
class_name ViewBakerResource #TODO rename to ShipModule
extends Resource

enum Type { HULL, HULL_EXT, ENGINE } #TODO: use this type in ship designer
enum TextureType { DIFFUSE, NORMAL, MASK, HEAT, EMISSION }

@export var type: Type
@export var allowed_ext: Array[ViewBakerResource] = []

@export_group("textures")
@export var diffuse: Texture2D
@export var normal: Texture2D
@export var mask: Texture2D
@export var emission: Texture2D
@export var heat: Texture2D
@export_range(0, 1) var shininess: float = 0.5
@export var mergeable := true

@export_group("physics")
@export var pivot_point: Vector2
@export var polygon: Vector2ArrayResource # TODO: update to allow multiple polygons

@export_group("stats")
#@export var mass: float = 1.0
@export var heat_capacity: float = 500.0
@export var heat_radiation: float = 20.0

func texture(type: TextureType):
	match type:
		TextureType.DIFFUSE: return diffuse
		TextureType.NORMAL: return normal
		TextureType.MASK: return mask
		TextureType.EMISSION: return emission
		TextureType.HEAT: return heat
