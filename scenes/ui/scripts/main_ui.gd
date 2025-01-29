extends CanvasLayer

@export var _crosshair_image: Texture2D

@onready var game_over_container: GameOverPanel = %GameOverContainer
@onready var game_ui: Container = %GameUI
@onready var ship_designer_ui: ShipDesignerUI = %ShipDesignerContainer

func _ready() -> void:
	process_priority = 999
	MainState.player_ship_updated.connect(_on_player_updated)
	game_over_container.open_ship_designer.connect(open_ship_designer)
	ship_designer_ui.closed.connect(show_game_ui)
	ship_designer_ui.finished.connect(_on_ship_design_changed)

func open_ship_designer() -> void:
	hide_game_ui()
	ship_designer_ui.open()
	ship_designer_ui.set_blueprint(MainState.main_scene.ship_blueprint.duplicate())

# FIXME: _design is not used inside
func _on_ship_design_changed(blueprint: ShipBlueprint, _design: ShipDesignData) -> void:
	MainState.main_scene.ship_blueprint = blueprint
	show_game_ui()

func hide_game_ui() -> void:
	game_ui.visible = false

func show_game_ui() -> void:
	game_ui.visible = true

func _on_player_updated(player_ship: Spaceship) -> void:
	if player_ship == null:
		Input.set_custom_mouse_cursor(null)
	else:
		Input.set_custom_mouse_cursor(_crosshair_image, Input.CURSOR_ARROW, Vector2(16.0, 16.0))
