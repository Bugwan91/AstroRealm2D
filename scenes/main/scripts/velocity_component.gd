class_name VelocityConponent
extends Node

@export var velocity := Vector2.ZERO

@onready var parent: Node2D

func _ready():
	parent = get_parent() as Node2D
	parent.add_to_group("ignore_floating")

func _process(delta):
	parent.position += (FloatingOrigin.velocity + velocity) * delta
