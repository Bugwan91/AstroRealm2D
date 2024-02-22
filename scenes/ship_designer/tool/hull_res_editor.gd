@tool
extends Node2D

@export var res: HullBakerResource:
	set(value):
		res = value
		_update_editor()

@onready var view: Sprite2D = %ResourceView
@onready var hull_placceholder: Sprite2D = %hull_placceholder
@export var heat_gradient: Texture2D

func _get_tool_buttons() -> Array:
	return [update]

func update():
	_update_res()

func _reset():
	if not is_instance_valid(view): return
	view.texture = null
	hull_placceholder.texture = null
	view.position = Vector2.ZERO

func _update_editor():
	if not is_instance_valid(view): return
	if res == null:
		_reset()
		return
	view.texture = res.diffuse
	hull_placceholder.texture = res.parent.diffuse if res.parent != null else null
	view.position = -res.pivot_point

func _update_res():
	if not is_instance_valid(view) or res == null: return
	res.pivot_point = -view.position
