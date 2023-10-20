extends VBoxContainer

@onready var _main_state: MainState = get_node("/root/MainState")

var labels := {}

func _process(_delta):
	for key in _main_state.debug:
		set_label(key, _main_state.debug[key])

func set_label(key, value):
	if not labels.has(key):
		var label = Label.new()
		labels[key] = label
		add_child(label)
	labels[key].text = key + ": " + value
