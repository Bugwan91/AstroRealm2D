class_name ShipDestroyEffect
extends Node2D

@onready var fire: GPUParticles2D = %Fire
@onready var smoke: GPUParticles2D = %Smoke
@onready var sparcles: GPUParticles2D = %Sparcles

func run():
	smoke.emitting = true
	fire.emitting = true
	sparcles.emitting = true
