extends Node

class_name ShipControlAssistant

@export var enabled := false

enum Action {STOP, ROTATE}

#
# delta_vel = vel * delta
# delta_torque = torque * inertia_inv * delta
#
