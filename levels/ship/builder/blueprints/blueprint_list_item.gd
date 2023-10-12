class_name BlueprintListItem
extends CenterContainer

@onready var view = %View

func setup(texture: Texture2D):
	print(view)
	view.texture = texture
