@tool
extends Node2D

@export var res: HullBakerResource: set = _set_resource

@onready var resource_editor = %ResourceEditor

func _set_resource(value: HullBakerResource):
	res = value
	if res == null: return
	resource_editor.res = res
