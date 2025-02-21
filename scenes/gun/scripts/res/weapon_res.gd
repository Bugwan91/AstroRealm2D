class_name WeaponRes
extends Resource

@export var scene: PackedScene
@export var color: Color = Color.FIREBRICK

# TODO: Need handle different damage types and extra damage modifiers, like penetration
## Single projectile or per seccond for beam
@export_range(0, 1000) var damage: float = 1
## Only for projectiles
@export_range(0.1, 32.0) var fire_rate: float = 1
@export var salvo: bool = false

## Full damage range
@export_range(0, 5000) var effective_range := 1000.0
## Damage reduced with extra range
@export_range(0, 5000) var extra_range := 1000.0

## Only for projectiles
@export_range(0, 10000) var projectile_speed := 1000.0

## Radians. Do no make sence for beams
@export var accuracy: float = 0.02 # 1.15 deg
## Radians. Do no make sence for beams
@export var overheat_accuracy: float = 0.04 # 2.3 deg

## Recoil force applyed to ship on fire
@export_range(0, 1000) var recoil_impulse := 0.0

@export_category("Heat") #TODO: heat resource?
@export var heat_generation: float = 1
@export var heat_capacity: float = 10
@export var heat_radiating: float = 1
@export var heat_transfer: float = 1

@export_category("Ammo & Energy")
## Rounds per clip, only for projectile weapons. 0 is infinite
@export_range(0, 500) var clip_size: int = 0
## Reload clips time for projectile weapons, cooldown for beams.
@export_range(0, 1000) var reload_time: float = 0
## Time after start firing and before actual fire
@export_range(0, 20) var charging_time: float = 0.0
@export_range(0, 10000) var energy_cost: float = 0.0
## Max duration of fire. 0 is infinite. Actual for beams
## TODO: Maybe I should use overheat instead, but it may be no so flexible
@export_range(0, 100) var fire_duration_max: float = 0.0

func create() -> Gun:
	var weapon: Gun = scene.instantiate()
	weapon.init(self)
	return weapon
