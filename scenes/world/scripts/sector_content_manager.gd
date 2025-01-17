class_name SectorContentManager
extends Resource

## Override
func init(sector_size: float):
	pass

## Override
func load_content(sector: Vector2):
	pass

## Override
func unload_content(items: Array[Node2D]):
	pass

## Override if needed
func replace_content(items: Array[Node2D], offset: Vector2):
	pass
