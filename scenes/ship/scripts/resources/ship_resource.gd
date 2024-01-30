class_name ShipResource
extends Resource

@export var textures: ShipTexturesRes

@export_range(0, 100000) var max_speed := 10000.0
@export_range(0, 5000) var main_thrust := 500.0
@export_range(0, 2000) var maneuver_thrust := 200.0
