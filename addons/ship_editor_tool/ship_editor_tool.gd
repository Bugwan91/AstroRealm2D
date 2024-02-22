@tool
extends EditorPlugin

const controls_scene: PackedScene = preload("res://addons/ship_editor_tool/controls.tscn")

var controls: ShipEditorToolControls

func _enter_tree():
	controls = controls_scene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, controls)

func _exit_tree():
	remove_control_from_docks(controls)
	controls.free()
