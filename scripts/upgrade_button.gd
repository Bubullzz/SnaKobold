extends Control

@export var upgrade : Upgrade
@export var manager : CanvasLayer

func _ready():
	%Button.text = upgrade.text

func _on_button_pressed() -> void:
	upgrade.on_selected()
	manager.end_upgrade_sequence()
