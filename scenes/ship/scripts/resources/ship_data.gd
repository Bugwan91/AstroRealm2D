class_name ShipData
extends Resource

@export var flight_model: ShipFlightModelData
@export var design: ShipDesignData
@export var blueprint: ShipBlueprint

func clone() -> ShipData:
	var data:= ShipData.new()
	data.flight_model = flight_model.duplicate()
	data.design = design.duplicate()
	return data

func is_editable() -> bool:
	return is_instance_valid(blueprint)
