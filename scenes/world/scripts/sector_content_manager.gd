class_name SectorContentManager
extends Resource

## Override
func init(sector_size: float):
	pass

## Override
func load_content(sector: Vector2):
	pass

## Override
func unload_content(items: Array[GridItem]):
	pass

## Override if needed
func replace_content(items: Array[GridItem], offset: Vector2):
	pass
