class_name Debug
extends Node

var debug_messages := {}
var debug_pointer: Node2D

func info(key: String, value):
	debug_messages[key] = str(value)

func list(list):
	for key in list:
		debug_messages[key] = list[key]
