class_name BaseView
extends Sprite2D

@export_range(0, 50) var max_emission := 2.0

func set_temperature(temperature: float) -> void:
	material.set("shader_parameter/heat", temperature)

func set_emission(emission: float) -> void:
	set_emission_absolute(emission * max_emission)

func set_emission_absolute(emission: float) -> void:
	material.set("shader_parameter/emission", emission)

func set_emission_color(color: Color) -> void:
	material.set("shader_parameter/emission_color", color)
