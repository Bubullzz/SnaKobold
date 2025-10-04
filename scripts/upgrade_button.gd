extends Control

class_name UpgradeButton 
@export var upgrade : Upgrade
@export var manager : CanvasLayer

func enable():
	%Button.disabled = false

func disable():
	%Button.disabled = true
	
func focus_me():
	%Button.grab_focus()

func set_upgrade(up : Upgrade):
	upgrade = up
	%Title.text = upgrade.title
	%UpgradeText.text = upgrade.get_text()
	%UpgradeIcon.texture = upgrade.icon

func _on_button_pressed() -> void:
	upgrade.on_selected()
	manager.end_upgrade_sequence()
