class_name ShipViewSubBaker
extends SubViewport

func bake() -> Texture2D:
	return get_viewport().get_texture()
