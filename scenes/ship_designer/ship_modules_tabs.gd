@tool
extends TabContainer

@export var hull_icon: Texture2D
@export var cocpit_icon: Texture2D
@export var engine_icon: Texture2D
@export var style_icon: Texture2D

func _ready():
	set_tab_icon(0, hull_icon)
	set_tab_icon(1, cocpit_icon)
	set_tab_icon(2, engine_icon)
	set_tab_icon(3, style_icon)
	set_tab_title(0, "")
	set_tab_title(1, "")
	set_tab_title(2, "")
	set_tab_title(3, "")
