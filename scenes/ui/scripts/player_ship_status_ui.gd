extends PanelContainer

@onready var health: ProgressBar = %HealthProgressBar
@onready var shield: ProgressBar = %ShieldProgressBar
@onready var heat: TextureProgressBar = %HeatProgressBar
@onready var speed: ProgressBar = %SpeedProgressBar

var player: Spaceship

func _ready() -> void:
	visible = false
	PlayerManager.instance.ship_spawned.connect(_on_player_ship_updated)
	PlayerManager.instance.ship_destroyed.connect(_on_player_destroyed)

func _process(_delta: float) -> void:
	if player == null: return
	heat.value = player.heat.temperature
	speed.value = player.speed / player.get_max_speed()

func _on_player_ship_updated(new_player_ship: Spaceship) -> void:
	player = new_player_ship
	health.value = player.main_hp.hp_percentage
	visible = true
	player.main_hp.damaged.connect(_on_health_update)

func _on_player_destroyed() -> void:
	visible = false
	player = null

func _on_health_update(value: float, _max: float) -> void:
	health.value = value / _max
