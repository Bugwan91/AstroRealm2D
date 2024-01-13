class_name ShipBakerStyleSelector
extends GridContainer

@export var empty_allowed := false
@export var item_view_scene: PackedScene = preload("res://scenes/ship_designer/item_preview.tscn")
@export var textures: Array[Texture2D]:
		set(value):
			textures = value
			_init_textures()

var update_blueprint: Callable

var selected_index: int = -1

func _ready():
	_init_empty_item()
	if not textures.is_empty():
		_init_textures()

func init_selection(data: Resource):
	if data == null: return
	for index in range(0, textures.size()):
		if textures[index].resource_path == data.resource_path:
			if selected_index != -1:
				_get_preview(selected_index).is_selected = false
			selected_index = index
			_get_preview(selected_index).is_selected = true
			return

func _init_textures():
	for index in range(0, textures.size()):
		var item_view = _init_item_preview(index)
		item_view.texture = textures[index]
		item_view.update_view()

func _init_item_preview(index: int) -> ShipDesignerItemPreview:
	var preview: ShipDesignerItemPreview = item_view_scene.instantiate()
	add_child(preview)
	preview.index = index
	preview.is_selected = index == selected_index
	preview.selected.connect(_on_selection)
	return preview

func _init_empty_item():
	if empty_allowed:
		_init_item_preview(-1).update_view()

func _get_preview(index: int) -> ShipDesignerItemPreview:
	return get_children()[index + 1 if empty_allowed else index]

func _on_selection(index: int):
	if index == selected_index: return
	_get_preview(selected_index).is_selected = false
	selected_index = index
	if not textures.is_empty():
		update_blueprint.call(textures[selected_index] if selected_index != -1 else null)
