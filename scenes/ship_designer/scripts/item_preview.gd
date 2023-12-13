class_name ShipDesignerItemPreview
extends CenterContainer

signal selected(index)

@export var index: int
@export var resource: ViewBakerResource: set = _set_resource
@export var texture: Texture2D: set = _set_texture

@export var _empty_texture: Texture2D
@export var _cockpit_image: Texture2D
@export var _engine_image: Texture2D

@export_group("style")
@export var _default_style: StyleBox
@export var _selected_style: StyleBox

@onready var _item_view: Sprite2D = %ItemView
@onready var _outline_panel: Panel = %OutlinePanel

var is_selected: bool = false: set = _set_selection

var _cockpit: Sprite2D
var _engines: Array[Sprite2D]

func _ready():
	_outline_panel.gui_input.connect(_handle_mouse_click)

func _set_texture(new_texture: Texture2D):
	texture = new_texture
	#update_view()

func _set_resource(new_resource: ViewBakerResource):
	resource = new_resource
	#update_view()

func _set_selection(value: bool):
	is_selected = value
	if not is_instance_valid(_outline_panel): return
	_outline_panel.add_theme_stylebox_override("panel", _selected_style if is_selected else _default_style)

func update_view():
	if not is_instance_valid(_item_view): return
	if resource != null:
		_update_with_resource()
	else:
		_update_with_texture()

func _update_with_texture():
	var actual_texture := _empty_texture if texture == null else texture
	_item_view.texture = _item_view.texture.duplicate()
	_item_view.texture.diffuse_texture = actual_texture
	_item_view.material = CanvasItemMaterial.new()
	_item_view.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED

func _update_with_resource():
	if resource == null: return
	_item_view.texture = _item_view.texture.duplicate()
	_item_view.material = _item_view.material.duplicate()
	_item_view.texture.diffuse_texture = resource.diffuse
	_item_view.texture.normal_texture = resource.normal
	_item_view.material.set("shader_parameter/emission_texture", resource.emission)
	_item_view.material.set("shader_parameter/specular_texture", resource.specular)
	#_item_view.material.set("shader_parameter/shininess", resource.shininess)
	_update_placeholders()

func _update_placeholders():
	if resource != null and resource is HullBakerResource:
		_add_cockpit(resource)
		_add_engines(resource)
	else:
		_clear_placeholders()

func _clear_placeholders():
	if is_instance_valid(_cockpit):
		_cockpit.queue_free()
	for engine in _engines:
		engine.queue_free()

func _add_cockpit(hull: HullBakerResource):
	_cockpit = Sprite2D.new()
	_cockpit.texture = _cockpit_image
	_cockpit.modulate = Color(0.0, 0.2, 1.0, 0.7)
	_item_view.add_child(_cockpit)
	_cockpit.position = hull.cockpit_slot

func _add_engines(hull: HullBakerResource):
	for engine_slot in hull.engine_slots:
		var engine := Sprite2D.new()
		engine.texture = _engine_image
		engine.modulate = Color(1.0, 0.2, 0.0, 0.7)
		_item_view.add_child(engine)
		engine.position = engine_slot

func _handle_mouse_click(event: InputEvent):
	if event is InputEventMouseButton\
			and event.button_index == MOUSE_BUTTON_LEFT\
			and event.pressed:
		is_selected = true
		selected.emit(index)

