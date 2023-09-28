extends Node2D
class_name ModuleView

@export var type: ShipBaseBaker.TYPE = ShipBaseBaker.TYPE.BASE

@onready var base: Sprite2D = %Base
@onready var mask: Sprite2D = %Mask
@onready var emission: Sprite2D = %Emission

@export var base_texture: Texture
@export var mask_texture: Texture
@export var emission_texture: Texture

@onready var embeded = %Embeded

func _ready():
	#base.textue = base_texture
	#mask.textue = mask_texture
	#emission.textue = emission_texture
	pass

func _update_view_type():
	match type:
		ShipBaseBaker.TYPE.BASE:
			base.show()
			mask.hide()
			emission.hide()
		ShipBaseBaker.TYPE.MASK:
			mask.show()
			base.hide()
			emission.hide()
		ShipBaseBaker.TYPE.EMISSION:
			emission.show()
			base.hide()
			mask.hide()
	_update_embeded_views_type()

func _update_embeded_views_type():
	for view: ModuleView in embeded.get_children():
		view.type = type
