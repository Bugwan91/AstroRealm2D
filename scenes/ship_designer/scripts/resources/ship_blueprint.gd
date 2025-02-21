class_name ShipBlueprint
extends Resource

signal updated_part(type: Type, value: Resource)
signal updated_specular(value: float)
signal updated_metallic(value: float)

enum Type { HULL, HULL_EXT, STYLE }

@export var hull: HullBakerResource:
	set(value):
		hull = value
		updated_part.emit(Type.HULL, hull)

@export var hull_ext: ViewBakerResource:
	set(value):
		hull_ext = value
		updated_part.emit(Type.HULL_EXT, hull_ext)

@export var style: Texture2D:
	set(value):
		style = value
		updated_part.emit(Type.STYLE, style)

@export_range(-1, 1) var shininess: float = 0.0:
	set(value):
		shininess = value
		updated_specular.emit(shininess)
@export_range(-1, 1) var metallic: float = 0.0:
	set(value):
		metallic = value
		updated_metallic.emit(metallic)

@export var main_weapon: WeaponRes
@export var secondary_weapon: WeaponRes

@export var radar_item_config: RadarItemConfig
