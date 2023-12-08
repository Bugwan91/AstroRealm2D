class_name GameOverPanel
extends PanelContainer

@onready var respawn_button = %RespawnButton
@onready var ship_editor_button = %ShipEditorButton

func _ready():
	visible = not is_instance_valid(MainState.player_ship)
	MainState.player_dead.connect(_on_player_dead)
	respawn_button.pressed.connect(_respawn_player)

func _on_player_dead():
	visible = true

func _respawn_player():
	MainState.main_scene.spawn_player_ship()
	visible = false
