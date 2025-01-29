class_name WeaponSlots
extends Node2D

var slots: Array[WeaponSlot]

var enabled := true:
	set(value):
		for slot in slots:
			enabled = value
			slot.enabled = enabled

func setup(data: ShipDesignData) -> void:
	for slot_point in data.weapon_slots:
		var slot := WeaponSlot.new()
		slot.position = slot_point.position
		slot.rotation = slot_point.radian
		slots.append(slot)
		add_child(slot)

func add_weapon(weapon: Gun, index: int) -> void:
	assert(index < slots.size(), "Invalid weapon slot index")
	slots[index].add(weapon)

func connect_inputs(inputs: ShipInput) -> void:
	for slot in slots:
		slot.connect_input(inputs.data.firing_toggled)

func update_velocity(velocity: Vector2) -> void:
	for slot in slots:
		slot.update_velocity(velocity)

func block_weapons(value: bool) -> void:
	enabled = value
