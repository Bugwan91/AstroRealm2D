extends HBoxContainer

@onready var tracking: Label = %Tracking
@onready var tracking_distance: Label = %TrackingDistance
@onready var autopilot: Label = %Autopilot
@onready var autopilot_speed: Label = %AutopilotSpeed

@onready var _main_state: MainState = get_node("/root/MainState")

func _ready():
	tracking.visible = false
	autopilot.visible = false
	tracking_distance.visible = false
	autopilot_speed.visible = false

func _process(_delta):
	tracking.visible = _main_state.fa_tracking
	autopilot.visible = _main_state.fa_autopilot
	if _main_state.fa_tracking and _main_state.fa_tracking_distance > 0:
		tracking_distance.text = str(_main_state.fa_tracking_distance)
		tracking_distance.visible = true
	else:
		tracking_distance.visible = false
	if _main_state.fa_autopilot:
		autopilot_speed.text = str(_main_state.fa_autopilot_speed)
		autopilot_speed.visible = true
	else:
		autopilot_speed.visible = false
