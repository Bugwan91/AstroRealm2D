class_name ShipView
extends Sprite2D

func _ready():
	texture = CanvasTexture.new()
	material = material.duplicate()

func setup_textures(textures: ShipTexturesRes):
	if textures == null: return
	texture.diffuse_texture = textures.diffuse
	texture.normal_texture = textures.normal
	material.set("shader_parameter/emission_texture", textures.emision)
	material.set("shader_parameter/specular_texture", textures.specular)
	material.set("shader_parameter/shininess", textures.shininess)
