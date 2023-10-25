class_name BackgroundSprite
extends Sprite2D

var shift_scale: float 

func shift(shift: Vector2, zoom: float):
	material.set("shader_parameter/scale", shift_scale)
	material.set("shader_parameter/offset", shift)
	material.set("shader_parameter/zoom", zoom)
