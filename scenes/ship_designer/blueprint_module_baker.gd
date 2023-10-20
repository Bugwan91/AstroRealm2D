class_name BlueprintBaseBaker
extends SubViewport

@onready var blueprint: BaseBlueprint = %Blueprint

func setup(resource: BaseBlueprintResource) -> BlueprintBaseBaker:
	blueprint.resource = resource
	size = blueprint.size
	blueprint.position = size / 2
	return self

func bake(type: BaseBlueprint.Type) -> Texture2D:
	blueprint.update_view(type)
	await RenderingServer.frame_post_draw
	return get_texture()
