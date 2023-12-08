@tool
class_name ViewBakerResource
extends Resource

enum TextureType { DIFFUSE, MASK, NORMAL, EMISSION, SPECULAR }

@export var diffuse: Texture2D
@export var mask: Texture2D
@export var normal: Texture2D
@export var emission: Texture2D
@export var specular: Texture2D
@export var polygon: Vector2ArrayResource
@export var ontop: bool = false

func texture(type: TextureType):
	match type:
		TextureType.DIFFUSE: return diffuse
		TextureType.MASK: return mask
		TextureType.NORMAL: return normal
		TextureType.EMISSION: return emission
		TextureType.SPECULAR: return specular
