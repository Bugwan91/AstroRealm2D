class_name AssistantPointer
extends Node

enum DisplayStyle { ACTIVE, INACTIVE, HIDDEN }

@onready var pointer: Control = %Pointer
@onready var pointer_texture: TextureRect = %PointerTexture

@export var display: DisplayStyle = DisplayStyle.ACTIVE: set = _set_display_style
@export var active_color: Color
@export var inactive_color: Color

var _pivot: Vector2
var _position: Vector2

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	_update_position()

func update(new_position: Vector2, pivot: Vector2 = Vector2.ZERO) -> void:
	_pivot = pivot
	_position = new_position
	_update_position()
	pointer_texture.visible = true

func _update_position() -> void:
	## HACK: I should add zoom signa to camera
	pointer.position = _pivot + _position * CameraController.instance.zoom

func set_active() -> void:
	display = DisplayStyle.ACTIVE

func set_inactive() -> void:
	display = DisplayStyle.INACTIVE

func hide() -> void:
	display = DisplayStyle.HIDDEN

func _set_display_style(value: DisplayStyle) -> void:
	display = value
	match display:
		DisplayStyle.ACTIVE:
			pointer_texture.visible = true
			pointer_texture.modulate = active_color
		DisplayStyle.INACTIVE:
			pointer_texture.visible = true
			pointer_texture.modulate = inactive_color
		DisplayStyle.HIDDEN:
			pointer_texture.visible = false
