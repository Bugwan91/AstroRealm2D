@tool
extends SubViewport

@export var filename: String = "image"

func bake():
	#await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	img.flip_y()
	img.save_png("res://" + filename + ".png")

func _get_tool_buttons() -> Array:
	return [bake]
