extends PanelContainer

@onready var health: ProgressBar = %HealthProgressBar
@onready var shield: ProgressBar = %ShieldProgressBar
@onready var speed: ProgressBar = %SpeedProgressBar

var player: ShipRigidBody

func _ready():
	visible = false
	MainState.player_ship_updated.connect(_on_player_ship_updated)

func _process(delta):
	if player == null: return
	speed.value = player.absolute_velocity.length() / MainState.MAX_SPEED

func _on_player_ship_updated(new_player_ship: ShipRigidBody):
	player = new_player_ship
	if player == null:
		visible = false
		return
	health.value = player.health.health / player.health.max_health
	visible = true
	player.health.damaged.connect(_on_health_update)

func _on_health_update(value: float, max: float):
	health.value = value / max
