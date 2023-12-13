extends CanvasLayer

@export var _crosshair_image: Texture2D

@onready var game_over_container: GameOverPanel = %GameOverContainer
@onready var game_ui: Container = %GameUI
@onready var ship_designer_ui: ShipDesignerUI = %ShipDesignerContainer

func _ready():
	MainState.player_ship_updated.connect(_on_player_updated)
	game_over_container.open_ship_designer.connect(open_ship_designer)
	ship_designer_ui.closed.connect(show_game_ui)

func open_ship_designer():
	hide_game_ui()
	ship_designer_ui.open()

func hide_game_ui():
	game_ui.visible = false

func show_game_ui():
	game_ui.visible = true

func _on_player_updated(player_ship):
	if player_ship == null:
		Input.set_custom_mouse_cursor(null)
	else:
		Input.set_custom_mouse_cursor(_crosshair_image, Input.CURSOR_ARROW, Vector2(16.0, 16.0))
