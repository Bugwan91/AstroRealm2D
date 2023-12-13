class_name GameOverPanel
extends PanelContainer

signal open_ship_designer

@onready var respawn_button: Button = %RespawnButton
@onready var ship_designer_button: Button = %ShipEditorButton

func _ready():
	visible = not is_instance_valid(MainState.player_ship)
	MainState.player_dead.connect(_on_player_dead)
	respawn_button.pressed.connect(_respawn_player)
	ship_designer_button.pressed.connect(_open_ship_designer)

func _on_player_dead():
	visible = true

func _respawn_player():
	MainState.main_scene.spawn_player_ship()
	visible = false

func _open_ship_designer():
	open_ship_designer.emit()
