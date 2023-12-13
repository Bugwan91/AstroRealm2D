class_name ShipDesignerUI
extends PanelContainer

signal closed

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

func open():
	visible = true

func close():
	visible = false
	closed.emit()

func confirm():
	pass
