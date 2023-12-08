class_name ShipTexturesRes
extends Resource

@export var diffuse: Texture2D
@export var normal: Texture2D
@export var emision: Texture2D
@export var specular: Texture2D
@export_range(-1, 1) var shininess: float = 0.0
@export var polygon: PackedVector2Array
@export var thrusters: Array[PointResource]
@export var engines: PackedVector2Array

