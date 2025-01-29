# FIXME: Rename to PauseMenu
class_name GameOverPanel
extends PanelContainer

signal open_ship_designer

@onready var continue_button: Button = %ContinueButton
@onready var respawn_button: Button = %RespawnButton
@onready var ship_designer_button: Button = %ShipEditorButton

func _ready() -> void:
	visible = not is_instance_valid(MainState.player_ship)
	get_tree().paused = not visible
	MainState.player_dead.connect(_on_player_dead)
	continue_button.pressed.connect(_continue)
	continue_button.disabled = not is_instance_valid(MainState.player_ship)
	respawn_button.pressed.connect(_respawn_player)
	ship_designer_button.pressed.connect(_open_ship_designer)

func _on_player_dead() -> void:
	visible = true
	continue_button.disabled = true

func _continue() -> void:
	if is_instance_valid(MainState.player_ship):
		visible = false
		MainState.main_scene.pause(false)

func _respawn_player() -> void:
	var pos := MainState.player_ship.position if is_instance_valid(MainState.player_ship) else Vector2.ZERO
	MainState.main_scene.spawn_player_ship(pos)
	visible = false
	continue_button.disabled = false
	MainState.main_scene.pause(false)

func _open_ship_designer() -> void:
	open_ship_designer.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and is_instance_valid(MainState.player_ship):
		if not is_instance_valid(MainState.player_ship): return
		MainState.main_scene.pause(not visible)
		visible = not visible
