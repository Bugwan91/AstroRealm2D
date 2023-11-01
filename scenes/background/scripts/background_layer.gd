class_name BackgroundLayer
extends Node

@export_range(0.0000001, 1) var shift_scale: float = 1.0

var _sprites: Array[BackgroundSprite]

func _ready():
	for sprite in get_children():
		if sprite is BackgroundSprite:
			sprite.base_shift_scale = shift_scale
			_sprites.append(sprite)

func shift(shift_vector: Vector2, zoom: Vector2):
	for sprite in _sprites:
		sprite.shift(shift_vector, zoom)
