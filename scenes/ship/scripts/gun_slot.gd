class_name GunSlot
extends Marker2D

func add_gun(gun: Gun):
	owner.remove_child(gun)
	add_child(gun)
	gun.position = Vector2.ZERO
