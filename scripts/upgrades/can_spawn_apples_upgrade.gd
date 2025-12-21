extends Upgrade

func _ready():
	title = "Apple Spawning"
	
# Scamming people lol, it does nothing
func on_selected():
	print("Selected first Apple Spawn Upgrade")
	SnakeProps.update_juice(1000)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)
	
func get_text()->String:
	return "Press SPACE to spend 1000 Juice and spawn another apple !"
