class_name ShipResource
extends Resource

@export var texture: Texture2D
@export var normal_map: Texture2D
@export var emission_map: Texture2D
@export var specular_map: Texture2D
@export var shape: Vector2ArrayResource
@export var thrusters_position: PointsArrayResource

@export_range(0, 10000) var max_speed := 2000.0
@export_range(0, 1000) var main_thrust := 500.0
@export_range(0, 500) var maneuver_thrust := 200.0

@export_range(0, 1) var FA_accuracy := 0.9
@export_range(0, 10) var FA_accuracy_damp := 0.1
@export_range(0, 1) var BA_accuracy := 1.0
@export_range(0, 10) var BA_accuracy_damp := 0.1
