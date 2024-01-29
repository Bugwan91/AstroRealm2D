class_name WeaponSlots
extends Node2D

var slots: Array[Node2D]

func setup(data: ShipTexturesRes):
	for slot_point in data.weapon_slots:
		var slot = Node2D.new()
		slot.position = slot_point.position
		slot.rotation = slot_point.radian
		add_child(slot)
		slots.append(slot)

func add_weapon(weapon: Gun):
	for slot in slots:
		slot.add_child(weapon) # TODO: wil not work for multyweapons
