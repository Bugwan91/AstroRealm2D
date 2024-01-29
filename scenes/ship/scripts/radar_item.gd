class_name RadarItem
extends Node2D

@export var texture: Texture2D
@export var color: Color = Color(1.0, 0.1, 0.3)
var icon: Sprite2D

func _ready():
	if owner.is_player:
		color = Color(0.0, 0.7, 1.0)

func init():
	icon = Sprite2D.new()
	icon.material = material
	icon.texture = texture
	icon.scale = Vector2.ONE * 0.5
	icon.modulate = color
	icon.modulate.a = 0.2

func clear():
	icon.queue_free()

func update(view_r: float, radar_r: float):
	if not is_instance_valid(icon): return
	icon.rotation = global_rotation
	icon.position = global_position * view_r / radar_r + view_r * Vector2.ONE
