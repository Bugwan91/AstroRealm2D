extends SubViewport
class_name ShipBaseBaker

enum TYPE { BASE, MASK, EMISSION }

@export var type: ShipBaseBaker.TYPE = ShipBaseBaker.TYPE.BASE:
	get:
		return type
	set(value):
		type = value
		view.type = type

@onready var view: ModuleView = %View

func bake(type: TYPE) -> Texture:
	view.type = type
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture()

@onready var sprite_2d = $"../Sprite2D"
func _ready():
	#sprite_2d.texture = await bake(TYPE.BASE)
