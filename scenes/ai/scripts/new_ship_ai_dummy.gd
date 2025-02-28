class_name AIShipInput
extends ShipInput

@export var controlled_ship: Spaceship

enum AIM { NONE, MAIN, SECCONDARY }

var aim: AIM = AIM.NONE

func _ready() -> void:
	MainState.player_ship_spawned.connect(_on_player_ship_updated)
	aim_with_main()

func _process(delta: float) -> void:
	#data.strafe = Vector2(0.5, 0.0)
	fire(
		(controlled_ship.transform.x.dot(
			controlled_ship._main_weapon_slot.aim_point.normalized()
		) > 0.98)\
		and controlled_ship._main_weapon_slot.aim_point.length()\
		< (controlled_ship._main_weapon_slot.weapon_resource.effective_range\
			+ controlled_ship._main_weapon_slot.weapon_resource.extra_range * 0.8)
		)

func _on_player_ship_updated(player: Spaceship):
	data.target = player._radar_item if is_instance_valid(player) else null

func update_target_point() -> Vector2:
	match aim:
		AIM.MAIN: 
			data.target_point = controlled_ship._main_weapon_slot.aim_point + controlled_ship.position
		AIM.SECCONDARY:
			pass # TODO: update this when seccondary weapon slot will be implemented
			#data.target_point = controlled_ship._seccondary_weapon_slot.aim_point + controlled_ship.position
	return data.target_point

#region Actions
func move(direction: Vector2) -> void:
	DebugDraw2d.line_vector(controlled_ship.position, direction * 200.0, Color.AQUA, 2.0)
	data.strafe = direction

func aim_with_main():
	aim = AIM.MAIN

func aim_with_Seccondary():
	aim = AIM.SECCONDARY

func unaim():
	aim = AIM.NONE

func fire(value: bool):
	# TODO: automatically handle weapon group with current AIM option
	data.fire = value
#endregion
