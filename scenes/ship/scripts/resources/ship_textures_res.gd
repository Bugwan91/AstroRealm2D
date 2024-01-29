class_name ShipTexturesRes # TODO: rename to "ShipDesignResource"
extends Resource

@export_category("Textures")
@export var diffuse: Texture2D
@export var normal: Texture2D
@export var emision: Texture2D
@export var specular: Texture2D
@export_range(-1, 1) var shininess: float = 0.0

@export_category("Shape and thrusters")
@export var polygon: PackedVector2Array
@export var thrusters: Array[PointResource]
@export var engines: PackedVector2Array
@export var weapon_slots: Array[PointResource] 

