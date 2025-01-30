# FIXME: Rename to PauseMenu
class_name GameOverPanel
extends PanelContainer

signal open_ship_designer

@onready var continue_button: Button = %ContinueButton
@onready var respawn_button: Button = %RespawnButton
@onready var ship_designer_button: Button = %ShipEditorButton
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	visible = not PlayerManager.instance.is_alive()
	get_tree().paused = not visible
	PlayerManager.instance.ship_spawned.connect(_on_player_spawned)
	PlayerManager.instance.ship_destroyed.connect(_on_player_dstroyed)
	continue_button.pressed.connect(_continue)
	continue_button.disabled = not PlayerManager.instance.is_alive()
	respawn_button.pressed.connect(_respawn_player)
	ship_designer_button.pressed.connect(_open_ship_designer)
	exit_button.pressed.connect(_exit)

func open(paused: bool = true) -> void:
	visible = true
	if paused:
		MainState.main_scene.pause()

func close() -> void:
	visible = false
	MainState.main_scene.pause(false)

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _continue() -> void:
	if PlayerManager.instance.is_alive():
		close()

func _respawn_player() -> void:
	PlayerManager.instance.respawn_player_ship()

func _on_player_spawned(_ship: Spaceship) -> void:
	continue_button.disabled = false
	close()

func _on_player_dstroyed() -> void:
	open(false)
	continue_button.disabled = true

func _open_ship_designer() -> void:
	open_ship_designer.emit()

func _exit() -> void:
	MainState.main_scene.exit_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape")\
		and PlayerManager.instance.is_alive():
		toggle()
