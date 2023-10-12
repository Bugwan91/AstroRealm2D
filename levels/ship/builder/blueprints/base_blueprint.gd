class_name BaseBlueprint
extends Node2D

enum Type {BASE, MASK, EMISSION}

@onready var _base: Sprite2D = %Base
@onready var _mask: Sprite2D = %Mask
@onready var _emission_mask: Sprite2D = %Emission

var resource: BaseBlueprintResource: set = _set_resource
var size: Vector2

func update_view(type: Type):
	match type:
		Type.BASE:
			_base.show()
			_mask.hide()
			_emission_mask.hide()
		Type.MASK:
			_base.hide()
			_mask.show()
			_emission_mask.hide()
		Type.EMISSION:
			_base.hide()
			_mask.hide()
			_emission_mask.show()

func _set_resource(value: BaseBlueprintResource):
	resource = value
	_base.texture = resource.base_texture
	_mask.texture = resource.mask
	_emission_mask.texture = resource.emisison_mask
	size = _base.texture.get_size()
