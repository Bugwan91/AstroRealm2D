class_name AssistantPointer
extends Node

@onready var pointer = %Pointer
@onready var pointer_texture = %PointerTexture

@export var in_range_color: Color
@export var out_range_color: Color

var _pivot: Vector2
var _position: Vector2

func _ready():
	pointer_texture.visible = false

func _process(_delta):
	_update_position()

func update(new_position: Vector2, pivot: Vector2 = Vector2.ZERO, in_range: bool = true):
	_pivot = pivot
	_position = new_position
	pointer_texture.modulate = in_range_color if in_range else out_range_color
	_update_position()
	pointer_texture.visible = true

func disable():
	pointer_texture.visible = false

func _update_position():
	var zoom = get_viewport().get_camera_2d().zoom
	pointer.position = _pivot + _position * zoom
