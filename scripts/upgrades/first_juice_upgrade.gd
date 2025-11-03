extends Upgrade

func _ready():
	title = "Some... Juice ?"
	
func get_text()->String:
	return "Eat them and get some Juice.\nEat multiple in a row and get MORE Juice."


func on_selected():
	print("Selected first Juice Spawn Upgrade")
	Juice.instantiate(SnakeProps.SM, SnakeProps.SM.body[0])
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)
