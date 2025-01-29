class_name BackgroundLayer
extends Node2D

@export var distance: float = 0.0

var _sprites: Array[BackgroundSprite]

func _ready() -> void:
	for sprite in get_children():
		if sprite is BackgroundSprite:
			sprite.distance = distance
			_sprites.append(sprite)

func shift(shift_vector: Vector2, zoom: Vector2) -> void:
	for sprite in _sprites:
		sprite.shift(shift_vector, zoom)
