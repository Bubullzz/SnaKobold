extends Control

@export var upgrade : Upgrade
@export var manager : CanvasLayer

func enable():
	%Button.disabled = false

func disable():
	%Button.disabled = true
	
func focus_me():
	%Button.grab_focus()

func _ready():
	%Button.text = upgrade.text

func _on_button_pressed() -> void:
	upgrade.on_selected()
	manager.end_upgrade_sequence()
