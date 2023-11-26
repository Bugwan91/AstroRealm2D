@tool
class_name ShipView
extends Sprite2D

func setup_textures(diffuse: Texture2D, normal: Texture2D, emission: Texture2D, specular: Texture2D):
	texture = CanvasTexture.new()
	texture.diffuse_texture = diffuse
	texture.normal_texture = normal
	var unique_material = material.duplicate()
	unique_material.set("shader_parameter/emission_texture", emission)
	unique_material.set("shader_parameter/specular_texture", specular)
	material = unique_material
