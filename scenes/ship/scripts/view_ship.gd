class_name ShipView
extends BaseView

func _ready():
	texture = CanvasTexture.new()
	material = material.duplicate()

func setup_textures(design: ShipDesignData):
	if design == null: return
	texture.diffuse_texture = design.diffuse
	texture.normal_texture = design.normal
	material.set("shader_parameter/shininess", design.shininess)
	material.set("shader_parameter/mask_texture", design.mask)
	material.set("shader_parameter/emission_texture", design.emision)
	material.set("shader_parameter/heat_texture", design.heat)

func set_emission_color(color: Color):
	# TODO Not sure that Color can be passed to vec3 shader param
	material.set("shader_paramener/emission_color", color)
