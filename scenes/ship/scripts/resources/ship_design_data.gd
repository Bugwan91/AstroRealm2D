class_name ShipDesignData
extends Resource

@export_category("Textures")
@export var diffuse: Texture2D
@export var normal: Texture2D
@export var mask: Texture2D
@export var emision: Texture2D
@export var heat: Texture2D
@export_range(-1, 1) var shininess: float = 0.0
@export_range(-1, 1) var metallic: float = 0.0
@export var view_scale := 1.0

@export_category("Shape and thrusters")
@export var polygon: PackedVector2Array
@export var thrusters: Array[PointResource]
@export var main_weapon_points: Array[PointResource]
@export var secondary_weapon_points: Array[PointResource]

@export_category("Weapons & Modules")
@export var main_weapon: WeaponRes
@export var secondary_weapon: WeaponRes
