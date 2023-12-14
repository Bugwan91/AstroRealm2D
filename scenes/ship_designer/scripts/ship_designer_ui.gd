class_name ShipDesignerUI
extends PanelContainer

signal closed
signal finished(blueprint: ShipBlueprint, design: ShipTexturesRes)

@export var ship_blueprint: ShipBlueprint

@onready var hull_selector: ShipBakerItemSelector = %HullSelector
@onready var hull_ext_selector: ShipBakerItemSelector = %HullExtSelector
@onready var cockpit_selector: ShipBakerItemSelector = %CockpitSelector
@onready var engine_selector: ShipBakerItemSelector = %EngineSelector
@onready var style_selector: ShipBakerItemSelector = %StyleSelector
@onready var baker: ShipBlueprintBaker = %Baker
@onready var ship_preview: ShipView = %ShipPreview

@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

func _ready():
	MainState.ship_designer = self
	cancel_button.pressed.connect(close)
	confirm_button.pressed.connect(confirm)
	hull_selector.update_blueprint = func(value: HullBakerResource):
		baker.blueprint.hull = value
	hull_ext_selector.update_blueprint = func(value: ViewBakerResource):
		baker.blueprint.hull_ext = value
	cockpit_selector.update_blueprint = func(value: ViewBakerResource):
		baker.blueprint.cockpit = value
	engine_selector.update_blueprint = func(value: ViewBakerResource):
		baker.blueprint.engine = value
	style_selector.update_blueprint = func(value: Texture2D):
		baker.blueprint.style = value
	baker.updated.connect(ship_preview.setup_textures)

func set_blueprint(blueprint: ShipBlueprint):
	baker.blueprint = blueprint
	baker.bake()
	hull_selector.init_selection(baker.blueprint.hull)
	hull_ext_selector.init_selection(baker.blueprint.hull_ext)
	cockpit_selector.init_selection(baker.blueprint.cockpit)
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
