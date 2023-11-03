class_name RadarItem
extends Node2D

@export var texture: Texture2D
var icon: Sprite2D

func init():
	icon = Sprite2D.new()
	icon.texture = texture
	icon.scale = Vector2.ONE * 0.3

func clear():
	icon.queue_free()

func update(size: float, radius: float):
	if not is_instance_valid(icon): return
	icon.rotation = global_rotation
	icon.position = Vector2.ONE * size + global_position * size / radius
