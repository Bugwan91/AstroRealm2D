class_name ChunkContentManager
extends Resource

## Override
func init(chunk_size: float):
	pass

## Override
## Will be called when new chunk loaded. Passing chunk position as an argument
func load_content(chunk: Vector2):
	pass

## Override
## Will be called on chunk unloading. Passing all nodes in the unloaded chunk
func unload_content(items: Array[Node2D]):
	pass

## Override if needed
## Optional
## FIXME: it is probaby not optional now, as there are no asteroid deletion on sides.
## Probably I can return boolean and check this in chunk to know if the unload_contedt should be called instead
func replace_content(items: Array[Node2D], offset: Vector2):
	pass
