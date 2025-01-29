extends VBoxContainer

var labels: Dictionary[String, Label] = {}

func _process(_delta: float) -> void:
	for key in MyDebug.debug_messages:
		set_label(key, MyDebug.debug_messages[key])

func set_label(key: String, value: Variant) -> void:
	if not labels.has(key):
		var label := Label.new()
		labels[key] = label
		add_child(label)
	labels[key].text = key + ": " + str(value)
