class_name RadarItem
extends Area2D

@export var texture: Texture2D
@export var icon_scale := 1.0
@export var icon_aspect := 1.0
@export var relative_scale := false
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
	icon.modulate = color
	icon.modulate.a = 0.2
	_update_scale()

func clear():
	icon.queue_free()

func update(view_r: float, radar_r: float):
	if not is_instance_valid(icon): return
	icon.rotation = global_rotation
	var view_scale := view_r / radar_r
	icon.position = global_position * view_scale + view_r * Vector2.ONE
	if relative_scale:
		_update_scale(view_scale)

func _update_scale(view_scale: float = 1.0):
	if not is_instance_valid(icon): return
	if relative_scale:
		MyDebug.list({
			"view_scale": view_scale,
			"icon_scale": icon_scale,
			"final_scale": view_scale * icon_scale
		})
	icon.scale = icon_scale * view_scale * Vector2(1.0, icon_aspect)
