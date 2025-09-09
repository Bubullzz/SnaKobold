extends Control

@export var upgrade : Upgrade

func _ready():
	%Button.text = upgrade.text

func _on_button_pressed() -> void:
	print("button clicked")
	upgrade.on_selected()
