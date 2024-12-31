class_name MovingNode
extends Node2D

@export var velocity := Vector2.ZERO

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	position += velocity * delta
