class_name WeaponSlots
extends Node2D

var slots: Array[WeaponSlot]

func setup(data: ShipDesignData):
	for slot_point in data.weapon_slots:
		var slot = WeaponSlot.new()
		slot.position = slot_point.position
		slot.rotation = slot_point.radian
		slots.append(slot)
		add_child(slot)

func add_weapon(weapon: Gun, index: int):
	assert(index < slots.size(), "Invalid weapon slot index")
	weapon.position = Vector2.ZERO
	slots[index].add(weapon)

func connect_inputs(inputs: ShipInput):
	for slot in slots:
		slot.connect_input(inputs.data.firing_toggled)
