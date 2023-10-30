@tool
extends Node

@export var filename: String = "image"
@export var style: Texture2D

@onready var base_baker: SubViewport = %BaseBaker
@onready var mask_baker: SubViewport = %MaskBaker
@onready var emission_baker: SubViewport = %EmissionBaker
@onready var stylizator_baker: SubViewport = %Stylizator

@onready var stylizator_view: Sprite2D = %StylizatorView

func _process(_delta):
	stylizator_view.texture = base_baker.get_viewport().get_texture()
	stylizator_view.material.set("shader_parameter/mask_texture", mask_baker.get_viewport().get_texture())
	stylizator_view.material.set("shader_parameter/style_texture", style)

func bake():
	var img = stylizator_baker.get_viewport().get_texture().get_image()
	img.save_png("res://scenes/ship/views/" + filename + ".png")
	var emission_img = emission_baker.get_viewport().get_texture().get_image()
	emission_img.save_png("res://scenes/ship/views/" + filename + "_emission.png")

func _get_tool_buttons() -> Array:
	return [bake]
