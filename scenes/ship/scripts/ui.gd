class_name ObjectUI
extends CanvasLayer

@onready var pivot = %Pivot
@onready var selection = %Selection
@onready var health_bar: ShipHealthProgressBar = %Health

var _is_player := false

func _ready():
	selection.visible = false
	health_bar.value = 1.0
	health_bar.visible = false
	_connect_health()
	MainState.player_ship_updated.connect(_player_updated)
	MainState.player_target_updated.connect(_target_updated)

func _process(_delta):
	var viewport = Vector2(get_viewport().get_size()) * 0.5
	var position = owner.extrapolator.canvas_position - viewport
	position = Vector2(
		min(abs(position.x * min(abs(viewport.y / position.y), 1.0)), viewport.x) * sign(position.x),
		min(abs(position.y * min(abs(viewport.x / position.x), 1.0)), viewport.y) * sign(position.y)
	)
	pivot.position = position + viewport
	pivot.scale = 1.2 * get_viewport().get_camera_2d().zoom

func display_health(value: float, max: float):
	health_bar.visible = value < max
	health_bar.value = value / max

func _connect_health():
	var health = get_node("../Health") as Health
	if is_instance_valid(health):
		health.damaged.connect(display_health)

func _player_updated(player: ShipRigidBody):
	_is_player = player == get_parent()
	health_bar.show_as_player() if player == get_parent() else health_bar.show_as_enemy()

func _target_updated(target: ShipRigidBody):
	selection.visible = target == get_parent()
