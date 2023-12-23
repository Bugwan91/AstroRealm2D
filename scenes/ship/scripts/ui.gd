class_name ObjectUI
extends CanvasLayer

@onready var pivot = %Pivot
@onready var selection = %Selection
@onready var health_bar: ShipHealthProgressBar = %Health

var _is_player := false
var _ship: ShipRigidBody
var _is_selected := false:
	set(value):
		_is_selected = value
		selection.visible = _is_selected
var _is_on_screen := false:
	set(value):
		_is_on_screen = value
		health_bar.visible = _is_on_screen and _is_health_visible
var _is_health_visible := false

func _ready():
	_ship = owner
	selection.visible = false
	health_bar.value = 1.0
	health_bar.visible = false
	MainState.player_ship_updated.connect(_player_updated)
	MainState.player_target_updated.connect(_target_updated)

func _process(_delta):
	var viewport = Vector2(get_viewport().get_size()) * 0.5
	var position = _ship.extrapolator.canvas_position - viewport
	_is_on_screen = abs(position.x) < viewport.x and abs(position.y) < viewport.y
	if not _is_visible(): return
	position = Vector2(
		min(abs(position.x * min(abs(viewport.y / position.y), 1.0)), viewport.x) * sign(position.x),
		min(abs(position.y * min(abs(viewport.x / position.x), 1.0)), viewport.y) * sign(position.y)
	)
	pivot.position = position + viewport
	pivot.scale = 1.5 * get_viewport().get_camera_2d().zoom

func _is_visible() -> bool:
	return _is_selected or _is_on_screen

func display_health(value: float, max: float):
	_is_health_visible = value < max
	if _is_on_screen and _is_health_visible:
		health_bar.value = value / max

func connect_health(health: Health):
	health.damaged.connect(display_health)

func _player_updated(player: ShipRigidBody):
	_is_player = player == get_parent()
	health_bar.show_as_player() if player == get_parent() else health_bar.show_as_enemy()

func _target_updated(target: ShipRigidBody):
	_is_selected = target == get_parent()
