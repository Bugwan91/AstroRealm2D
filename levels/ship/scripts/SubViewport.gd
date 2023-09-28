extends SubViewport

enum TYPE { BASE, MASK, EMISSION }

@export var filename: String

func _ready():
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	#img.convert(Image.FORMAT_RGBA8)
	img.save_png(filename)
