extends Node2D

@export var enabled := true

@onready var origin_body: FloatingOriginBody = MainState.player_ship

## Position of current (0,0)
var origin := Vector2.ZERO

## Delta position of current (0,0) from last frame
var shift := Vector2.ZERO

## Delta position of current (0,0) from last physics tick
var phys_shift := Vector2.ZERO

## Current velocity of world
var velocity := Vector2.ZERO:
	set(value):
		velocity_delta += value - velocity
		velocity = value

## Delta velocity of world from last frame
var velocity_delta := Vector2.ZERO

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
	last_physic_time = Time.get_ticks_usec() * 0.000001
	phys_shift = Vector2.ZERO
	velocity_delta = Vector2.ZERO
	MyDebug.info("origin", origin)
	MyDebug.info("origin velocity", velocity)
	MyDebug.info("speed", velocity.length())

func absolute_position(node: Node2D) -> Vector2:
	return node.position + origin

func _shift_objects():
	var time := Time.get_ticks_usec() * 0.000001
	shift = velocity * (time - last_update_time)
	origin += shift
	for node in MainState.main_scene.get_children():
		if node is Node2D and not node == origin_body and not node.is_in_group("ignore_floating"):
			node.position -= shift
	phys_shift -= shift
	last_update_time = time

func reset_origin(body: FloatingOriginBody):
	origin_body = body
	if not origin_body:
		velocity_delta = -velocity
		velocity = Vector2.ZERO
