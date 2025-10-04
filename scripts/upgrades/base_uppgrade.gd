extends Node2D

class_name Upgrade

@export var auto_select = false
var title = "Dummy title"
@export var icon : Texture2D

func _ready() -> void:
	if auto_select:
		print("auto-selected : ", self)
		call_deferred("on_selected")

func on_selected():
	print("selected Dummy")
	

func get_text()->String:
	return "Basic Text, this shit should be implemented !!!"
