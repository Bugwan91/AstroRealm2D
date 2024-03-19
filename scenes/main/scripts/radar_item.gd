class_name RadarItem
extends Area2D

@export var texture: Texture2D
@export var icon_scale := 1.0
@export var color: Color = Color(1.0, 0.1, 0.3)
var icon: Sprite2D

func _ready():
	monitoring = false
	collision_layer = 8
	collision_mask = 0

func init():
	icon = Sprite2D.new()
	icon.material = material
	icon.texture = texture
	icon.scale = Vector2.ONE * icon_scale
	icon.modulate = color
	icon.modulate.a = 0.2

func clear():
	icon.queue_free()

func update(view_r: float, radar_r: float):
	if not is_instance_valid(icon): return
	icon.rotation = global_rotation
	icon.position = global_position * view_r / radar_r + view_r * Vector2.ONE
