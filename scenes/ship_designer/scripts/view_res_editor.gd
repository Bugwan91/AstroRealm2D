@tool
extends Sprite2D

@export var res: ViewBakerResource: set = _set_resource

func _set_resource(value: ViewBakerResource):
	res = value
	texture = res.diffuse
