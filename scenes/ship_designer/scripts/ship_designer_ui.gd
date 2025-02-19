class_name ShipDesignerUI
extends PanelContainer

signal closed
signal finished(blueprint: ShipBlueprint, design: ShipDesignData)

@export var ship_blueprint: ShipBlueprint
@export var all_parts: ShipDesignerParts = preload("res://resources/ship_parts/all_parts.tres")

@onready var hull_selector: ShipBakerHullSelector = %HullSelector
@onready var hull_ext_selector: ShipBakerHullSelector = %HullExtSelector
@onready var style_selector: ShipBakerStyleSelector = %StyleSelector

@onready var specular_slider: Slider = %SpecSlider
var _specular := 0.0
@onready var metallic_slider: Slider = %MetSlider
var _metallic := 0.0

@onready var baker: ShipBlueprintBaker = %Baker
@onready var ship_preview: ShipView = %ShipPreview

@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

@onready var debug_diffuse: TextureRect = %DiffuseDebug
@onready var debug_normal: TextureRect = %NormalDebug
@onready var debug_mask: TextureRect = %MaskDebug
@onready var debug_emission: TextureRect = %EmissionDebug
@onready var debug_heat: TextureRect = %HeatDebug

var _specular_updating := false
var _metallic_updating := false

func _ready() -> void:
	_setup_selectors_data()
	cancel_button.pressed.connect(close)
	confirm_button.pressed.connect(confirm)
	hull_selector.update_blueprint = func(value: HullBakerResource) -> void:
		baker.blueprint.hull = value
	hull_ext_selector.update_blueprint = func(value: HullBakerResource) -> void:
		baker.blueprint.hull_ext = value
	style_selector.update_blueprint = func(value: Texture2D) -> void:
		baker.blueprint.style = value
	baker.updated.connect(_on_baker_updates)
	specular_slider.drag_started.connect(func():
		_specular_updating = true)
	specular_slider.drag_ended.connect(func():
		baker.blueprint.shininess = specular_slider.value
		_specular_updating = false)
	metallic_slider.drag_started.connect(func():
		_metallic_updating = true)
	metallic_slider.drag_ended.connect(func():
		baker.blueprint.metallic = metallic_slider.value
		_metallic_updating = false)

func _process(delta: float) -> void:
	if _specular_updating:
		baker.blueprint.shininess = specular_slider.value
	if _metallic_updating:
		baker.blueprint.metallic = metallic_slider.value

func _setup_selectors_data() -> void:
	hull_selector.resources = all_parts.hulls
	hull_ext_selector.resources = all_parts.hulls_ext
	style_selector.textures = all_parts.styles

func set_blueprint(blueprint: ShipBlueprint) -> void:
	baker.blueprint = blueprint
	baker.bake()
	hull_selector.init_selection(baker.blueprint.hull)
	hull_ext_selector.init_selection(baker.blueprint.hull_ext)
	style_selector.init_selection(baker.blueprint.style)

func open() -> void:
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func confirm() -> void:
	visible = false
	baker.design.shininess = _specular
	baker.design.metallic = _metallic
	finished.emit(baker.blueprint, baker.design)

func _on_baker_updates(baked_design: ShipDesignData) -> void:
	ship_preview.setup_textures(baked_design)
	ship_preview.scale = 2.0 * Vector2.ONE * baked_design.view_scale
	debug_diffuse.texture = baked_design.diffuse
	debug_normal.texture = baked_design.normal
	debug_mask.texture = baked_design.mask
	debug_emission.texture = baked_design.emision
	debug_heat.texture = baked_design.heat

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("escape"):
		get_viewport().set_input_as_handled()
		close()
