class_name ShipDesignerUI
extends PanelContainer

signal closed
signal finished(blueprint: ShipBlueprint, design: ShipDesignData)

@export var ship_blueprint: ShipBlueprint
@export var all_parts: ShipDesignerParts = preload("res://resources/ship_parts/all_parts.tres")

@onready var hull_selector: ShipBakerHullSelector = %HullSelector
@onready var hull_ext_selector: ShipBakerHullSelector = %HullExtSelector
@onready var engine_selector: ShipBakerPartSelector = %EngineSelector
@onready var style_selector: ShipBakerStyleSelector = %StyleSelector
@onready var baker: ShipBlueprintBaker = %Baker
@onready var ship_preview: ShipView = %ShipPreview

@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

func _ready():
	_setup_selectors_data()
	MainState.ship_designer = self
	cancel_button.pressed.connect(close)
	confirm_button.pressed.connect(confirm)
	hull_selector.update_blueprint = func(value: HullBakerResource):
		baker.blueprint.hull = value
	hull_ext_selector.update_blueprint = func(value: HullBakerResource):
		baker.blueprint.hull_ext = value
	engine_selector.update_blueprint = func(value: ViewBakerResource):
		baker.blueprint.engine = value
	style_selector.update_blueprint = func(value: Texture2D):
		baker.blueprint.style = value
	baker.updated.connect(ship_preview.setup_textures)

func _setup_selectors_data():
	hull_selector.resources = all_parts.hulls
	hull_ext_selector.resources = all_parts.hulls_ext
	engine_selector.resources = all_parts.engines
	style_selector.textures = all_parts.styles

func set_blueprint(blueprint: ShipBlueprint):
	baker.blueprint = blueprint
	baker.bake()
	hull_selector.init_selection(baker.blueprint.hull)
	hull_ext_selector.init_selection(baker.blueprint.hull_ext)
	engine_selector.init_selection(baker.blueprint.engine)
	style_selector.init_selection(baker.blueprint.style)

func open():
	visible = true

func close():
	visible = false
	closed.emit()

func confirm():
	visible = false
	finished.emit(baker.blueprint, baker.design)
