class_name KineticBody
extends Node2D

@export var velocity := Vector2.ZERO

var speed: float:
	get: return velocity.length()

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	position += velocity * delta
