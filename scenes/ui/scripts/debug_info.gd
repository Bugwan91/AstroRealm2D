extends VBoxContainer

var labels := {}

func _process(_delta):
	for key in MyDebug.debug_messages:
		set_label(key, MyDebug.debug_messages[key])

func set_label(key, value):
	if not labels.has(key):
		var label = Label.new()
		labels[key] = label
		add_child(label)
	labels[key].text = key + ": " + str(value)
