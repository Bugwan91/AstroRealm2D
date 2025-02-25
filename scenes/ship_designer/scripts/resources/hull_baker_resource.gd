@tool
class_name HullBakerResource
extends ViewBakerResource

#TODO inverse this dependency
signal parent_changed(parent: HullBakerResource)

@export var parent: HullBakerResource:
	set(value):
		parent = value
		parent_changed.emit(parent)

@export var thrusters: PointsArrayResource
@export var weapon_slots: PointsArrayResource

@export_range(0.001, 10000.0) var mass := 1.0

@export_range(0, 10000) var hp: int = 1000
