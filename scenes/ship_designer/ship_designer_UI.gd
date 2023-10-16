class_name ShipDesignerUI
extends CanvasLayer

@export var cocpits: Array[CocpitBlueprintResource]
@export var engines: Array[EngineBlueprintResource]

@onready var item_baker: BlueprintBaseBaker = %BlueprintModuleBaker
@onready var cocpits_list = %CocpitsList
@onready var engines_list = %EnginesList

const BLUEPRINT_LIST_ITEM = preload("res://scenes/ship_designer/blueprints/blueprint_list_item.tscn")

func _ready():
	visible = false
	_init_textures()

func _process(_delta):
	if Input.is_action_just_pressed("ship_builder"):
		visible = not visible

func _init_textures():
	for cocpit in cocpits:
		var list_item = BLUEPRINT_LIST_ITEM.instantiate() as BlueprintListItem
		cocpits_list.add_child(list_item)
		list_item.setup(cocpit.base_texture)
	for engine in engines:
		var list_item = BLUEPRINT_LIST_ITEM.instantiate() as BlueprintListItem
		engines_list.add_child(list_item)
		list_item.setup(engine.base_texture)
