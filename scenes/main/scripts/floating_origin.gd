extends Node2D

@export var enabled := true

@onready var origin_body: Spaceship = MainState.player_ship

var origin := Vector2.ZERO
var shift := Vector2.ZERO
var phys_shift := Vector2.ZERO

var velocity := Vector2.ZERO
var velocity_shift := Vector2.ZERO

var last_update_time: float
var last_physic_time: float

func _ready():
	process_priority = -1000
	MainState.player_ship_updated.connect(reset_origin)
	last_update_time = Time.get_ticks_usec() * 0.000001
	last_physic_time = last_update_time

func _process(delta):
	if not enabled: return
	_shift_objects()

func _physics_process(delta):
	if not enabled: return
	phys_shift = Vector2.ZERO
	last_physic_time = Time.get_ticks_usec() * 0.000001
	MyDebug.info("origin", origin)
	MyDebug.info("origin velocity", velocity)
	MyDebug.info("speed", velocity.length())
	_float_bodies()

func add_velocity(v: Vector2):
	velocity_shift -= v
	velocity += velocity_shift

func absolute_position(node: Node2D) -> Vector2:
	return node.position + origin

func reset_velocity_delta():
	velocity_shift = Vector2.ZERO

func update_origin():
	last_physic_time = Time.get_ticks_usec() * 0.000001
	origin_body.last_velocity = -velocity_shift

func update_body(body: FloatingOriginBody):
	#body.linear_velocity += velocity_delta
	body.last_velocity = body.linear_velocity

func _float_bodies():
	if not is_instance_valid(origin_body): return
	update_origin()
	for body in MainState.main_scene.get_children():
		if body is FloatingOriginBody and not body == origin_body:
			update_body(body)
	reset_velocity_delta()

func _shift_objects():
	var time := Time.get_ticks_usec() * 0.000001
	shift = velocity * (time - last_update_time)
	origin += shift
	for node in MainState.main_scene.get_children():
		if node is Node2D and not node == origin_body and not node.is_in_group("ignore_floating"):
			node.position += shift
	phys_shift += shift
	last_update_time = time

func reset_origin(body: FloatingOriginBody):
	origin_body = body
	if not origin_body:
		velocity_shift = -velocity
		velocity = Vector2.ZERO
