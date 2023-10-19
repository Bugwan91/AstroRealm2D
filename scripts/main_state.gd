extends Node

var ship_position := Vector2.ZERO
var ship_speed := 0
var ship_acceleration := 0
var fa_enabled := false
var fa_tracking := false
var fa_tracking_distance := 0.0
var fa_autopilot := false
var fa_autopilot_speed := 500.0

var debug := {}

func add_debug_info(key: String, value):
	debug[key] = str(value)
