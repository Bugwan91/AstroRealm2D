class_name ShipBlueprint
extends Resource

signal updated(type: Type, value: Resource)

enum Type { HULL, HULL_EXT, ENGINE, STYLE }

@export var hull: HullBakerResource:
	set(value):
		hull = value
		updated.emit(Type.HULL, hull)

@export var hull_ext: ViewBakerResource:
	set(value):
		hull_ext = value
		updated.emit(Type.HULL_EXT, hull_ext)

@export var engine: ViewBakerResource:
	set(value):
		engine = value
		updated.emit(Type.ENGINE, engine)

@export var style: Texture2D:
	set(value):
		style = value
		updated.emit(Type.STYLE, style)
