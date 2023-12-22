@tool
class_name ViewBakerResource
extends Resource

enum Type { HULL, HULL_EXT, COCKPIT, ENGINE } #TODO: use this type in ship designer
enum TextureType { DIFFUSE, MASK, NORMAL, EMISSION, SPECULAR }

@export var type: Type
@export_group("textures")
@export var diffuse: Texture2D
@export var mask: Texture2D
@export var normal: Texture2D
@export var emission: Texture2D
@export var specular: Texture2D
@export_group("behaviour")
@export var polygon: Vector2ArrayResource # TODO: update to allow multiple polygons
@export var ontop: bool = false

func texture(type: TextureType):
	match type:
		TextureType.DIFFUSE: return diffuse
		TextureType.MASK: return mask
		TextureType.NORMAL: return normal
		TextureType.EMISSION: return emission
		TextureType.SPECULAR: return specular
