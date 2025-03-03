class_name AIShipInput
extends ShipInput

@export var controlled_ship: Spaceship

enum AIM { NONE, MAIN, SECCONDARY }

var aim: AIM = AIM.NONE

func _ready() -> void:
	# _physics_process() should be called before BTPlayer
	process_physics_priority = -100
	MainState.player_ship_spawned.connect(_on_player_ship_updated)
	aim_with_main()

func _process(delta: float) -> void:
	#return
	fire(
		(controlled_ship.transform.x.dot(
			controlled_ship._main_weapon_slot.aim_point.normalized()
		) > 0.998)\
		and controlled_ship._main_weapon_slot.aim_point.length()\
		< (controlled_ship._main_weapon_slot.weapon_resource.effective_range\
			+ controlled_ship._main_weapon_slot.weapon_resource.extra_range * 0.8)
		)

func _physics_process(_delta: float) -> void:
	# Resseting all movements from previous tick
	reset_move()

func _on_player_ship_updated(player: Spaceship) -> void:
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
func move(control: Vector2) -> void:
	data.strafe += control

func reset_move() -> void:
	data.strafe = Vector2.ZERO

func aim_with_main() -> void:
	aim = AIM.MAIN

func aim_with_Seccondary() -> void:
	aim = AIM.SECCONDARY

func unaim() -> void:
	aim = AIM.NONE

func fire(value: bool) -> void:
	# TODO: automatically handle weapon group with current AIM option
	data.fire = value
#endregion
