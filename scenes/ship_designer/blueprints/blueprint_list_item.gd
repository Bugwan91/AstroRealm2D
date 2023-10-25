class_name BlueprintListItem
extends CenterContainer

@onready var view = %View

func setup(texture: Texture2D):
	view.texture = texture
