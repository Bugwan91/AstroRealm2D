class_name WeaponSlot
extends Node2D

var _weapon: Gun

func add(weapon: Gun):
	remove()
	_weapon = weapon
	add_child(_weapon)

func remove():
	if not is_instance_valid(_weapon): return
	remove_child(_weapon)
	_weapon.queue_free()

func connect_input(input: Signal):
	if not is_instance_valid(_weapon): return
	input.connect(_weapon.on_fire_input)
	
