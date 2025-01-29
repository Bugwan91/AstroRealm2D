class_name WeaponSlot
extends Node2D

var _weapon: Gun
var enabled := true:
	set(value):
		enabled = value
		if is_instance_valid(_weapon):
			_weapon.enabled = enabled

func add(weapon: Gun) -> void:
	weapon.position = Vector2.ZERO
	remove()
	_weapon = weapon
	add_child(_weapon)

func remove() -> void:
	if not is_instance_valid(_weapon): return
	remove_child(_weapon)
	_weapon.queue_free()

func connect_input(input: Signal) -> void:
	if not is_instance_valid(_weapon): return
	input.connect(_weapon.on_fire_input)

func update_velocity(velocity: Vector2) -> void:
	_weapon.velocity = velocity
