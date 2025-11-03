extends Upgrade

func _ready():
	title = "Apple Spawning"
	
# Scamming people lol, it does nothing
func on_selected():
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)
	
func get_text()->String:
	return "Press Q or O to spend 1000 Juice and spawn another apple !"
