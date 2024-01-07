class_name ShipHealthProgressBar
extends ProgressBar

@export var player_fill_style: StyleBoxFlat
@export var enemy_fill_style: StyleBoxFlat

func show_as_player():
	add_theme_stylebox_override("fill", player_fill_style)

func show_as_enemy():
	add_theme_stylebox_override("fill", enemy_fill_style)

func _ready():
	show_as_player()
