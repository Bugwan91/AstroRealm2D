@tool
class_name ShipView
extends Sprite2D

func setup_textures(textures: ShipTexturesRes):
	texture = CanvasTexture.new()
	texture.diffuse_texture = textures.diffuse
	texture.normal_texture = textures.normal
	var unique_material = material.duplicate()
	unique_material.set("shader_parameter/emission_texture", textures.emision)
	unique_material.set("shader_parameter/specular_texture", textures.specular)
	unique_material.set("shader_parameter/shininess", textures.shininess)
	material = unique_material
