extends VBoxContainer

var labels := {}

func _process(_delta):
	for key in MainState.debug_messages:
		set_label(key, MainState.debug_messages[key])

func set_label(key, value):
	if not labels.has(key):
		var label = Label.new()
		labels[key] = label
		add_child(label)
	labels[key].text = key + ": " + value
