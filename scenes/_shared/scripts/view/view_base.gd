class_name BaseView
extends Sprite2D

@export_range(0, 50) var max_emission := 2.0

func set_temperature(temperature: float):
	material.set("shader_parameter/heat", temperature)

func set_emission(emission: float):
	set_emission_absolute(emission * max_emission)

func set_emission_absolute(emission: float):
	material.set("shader_parameter/emission", emission)

func set_emission_color(color: Color):
	material.set("shader_parameter/emission_color", color)
