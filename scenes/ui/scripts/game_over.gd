class_name GameOverPanel
extends PanelContainer

signal open_ship_designer

@onready var respawn_button: Button = %RespawnButton
@onready var ship_designer_button: Button = %ShipEditorButton

func _ready() -> void:
	visible = not is_instance_valid(MainState.player_ship)
	get_tree().paused = not visible
	MainState.player_dead.connect(_on_player_dead)
	respawn_button.pressed.connect(_respawn_player)
	ship_designer_button.pressed.connect(_open_ship_designer)

func _on_player_dead() -> void:
	visible = true

func _respawn_player() -> void:
	MainState.main_scene.spawn_player_ship()
	visible = false
	MainState.main_scene.pause(false)

func _open_ship_designer() -> void:
	open_ship_designer.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if is_instance_valid(MainState.player_ship):
			MainState.main_scene.pause(not visible)
			visible = not visible
