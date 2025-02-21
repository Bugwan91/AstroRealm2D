class_name ShipData
extends Resource

@export var flight_model: ShipFlightModelData
@export var design: ShipDesignData
@export var blueprint: ShipBlueprint
@export var radar_item: RadarItemConfig

var _ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")

func create() -> Spaceship:
	var ship: Spaceship = _ship_scene.instantiate()
	ship.data = self.duplicate(true)
	return ship

func clone() -> ShipData:
	var data:= ShipData.new()
	data.flight_model = flight_model.duplicate()
	data.design = design.duplicate()
	return data

func is_editable() -> bool:
	return is_instance_valid(blueprint)
