@tool
extends Sprite2D

@export var path: String = "res://assets/backgrounds/noise/"
@export var filename: String = "0"

func save_image():
	texture.get_image().save_png(path + filename + ".png")

func _get_tool_buttons() -> Array:
	return [
		save_image
	]
