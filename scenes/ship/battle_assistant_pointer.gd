class_name BattleAssistantPointer
extends Node2D

@onready var pointer = %Pointer

@export var in_range_color: Color
@export var out_range_color: Color

func update(new_position: Vector2, in_range: bool = true):
	pointer.visible = true
	pointer.modulate = in_range_color if in_range else out_range_color
	var canvas_transform = get_global_transform_with_canvas()
	var zoom = get_viewport().get_camera_2d().zoom
	pointer.position = canvas_transform.origin + new_position * zoom

func disable():
	pointer.visible = false
