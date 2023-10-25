class_name BackgroundLayer
extends Node

@export_range(0.0000001, 1) var shift_scale: float = 1.0

var _sprites: Array[BackgroundSprite]

func _ready():
	for sprite in get_children():
		if sprite is BackgroundSprite:
			_sprites.append(sprite)
	get_viewport().size_changed.connect(_update_size)
	_update_size()

func shift(shift: Vector2, zoom: float):
	for sprite in _sprites:
		sprite.shift(shift, zoom)

func _update_size():
	var vp_size := Vector2(get_viewport().size)
	for sprite in _sprites:
		sprite.scale = Vector2.ONE * 4096.0 / sprite.texture.get_size()
		sprite.position = vp_size * 0.5
		sprite.shift_scale = shift_scale / 4096.0
	
