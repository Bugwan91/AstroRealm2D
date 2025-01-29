class_name ChunkContentManager
extends Resource

## Override
func init(_chunk_size: float) -> void:
	pass

## Override
## Will be called when new chunk loaded. Passing chunk position as an argument
func load_content(_chunk: Vector2) -> void:
	pass

## Override
## Will be called on chunk unloading. Passing all nodes in the unloaded chunk
func unload_content(_items: Array[Node2D]) -> void:
	pass

## Override if needed
## Optional
## FIXME: it is probaby not optional now, as there are no asteroid deletion on sides.
## Probably I can return boolean and check this in chunk to know if the unload_contedt should be called instead
func replace_content(_items: Array[Node2D], _offset: Vector2) -> void:
	pass
