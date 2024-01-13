class_name ShipBakerPartSelector
extends GridContainer

@export var empty_allowed := false
@export var item_view_scene: PackedScene = preload("res://scenes/ship_designer/item_preview.tscn")
@export var resources: Array[ViewBakerResource]:
	set(value):
		resources = value
		_init_items()

var update_blueprint: Callable

var selected_index: int = -1

func _ready():
	_init_empty_item()
	if not resources.is_empty():
		_init_items()

func init_selection(data: Resource):
	if data == null: return
	for index in range(0, resources.size()):
		if resources[index].resource_path == data.resource_path:
			_get_preview(selected_index).is_selected = false
			selected_index = index
			_get_preview(selected_index).is_selected = true
			return

func _init_items():
	for index in range(0, resources.size()):
		var item_view = _init_item_preview(index)
		item_view.resource = resources[index]
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
	if not resources.is_empty():
		update_blueprint.call(resources[selected_index] if selected_index != -1 else null)
