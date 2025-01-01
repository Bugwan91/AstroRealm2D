class_name ShipInput
extends Node2D

var data := ShipInputData.new()

func setup(ship: Spaceship):
	pass

func update_target_point() -> Vector2:
	return Vector2.ZERO
