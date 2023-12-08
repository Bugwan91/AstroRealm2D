class_name RadarItem
extends Node2D

@export var texture: Texture2D
var icon: Sprite2D

func init():
	icon = Sprite2D.new()
	icon.material = material
	icon.texture = texture
	icon.scale = Vector2.ONE * 0.5

func clear():
	icon.queue_free()

func update(view_r: float, radar_r: float):
	if not is_instance_valid(icon): return
	icon.rotation = global_rotation
	icon.position = global_position * view_r / radar_r
