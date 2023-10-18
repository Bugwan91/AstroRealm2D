extends MultiMeshInstance2D

@export var size: float = 2048

@onready var _mesh_instance = %Star

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	_do_distribution()

func _do_distribution():
	multimesh.mesh = _mesh_instance.mesh
	var bounds = Vector2(size, size)
	for i in multimesh.instance_count:
		var pos = Vector2(rng.randi_range(0, bounds.x), rng.randi_range(0, bounds.y))
		multimesh.set_instance_transform_2d(i, Transform2D(0, pos))
