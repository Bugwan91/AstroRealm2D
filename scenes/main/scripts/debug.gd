class_name Debug
extends Node

var debug_messages: Dictionary[String, Variant] = {}
var debug_pointer: Node2D

func info(key: String, value: Variant) -> void:
	debug_messages[key] = str(value)

func list(items: Dictionary[String, Variant]) -> void:
	debug_messages.merge(items, true)
