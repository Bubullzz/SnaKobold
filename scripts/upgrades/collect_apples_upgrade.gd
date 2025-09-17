extends Upgrade

@export var ApplesList: Node #Node containing all the Apples on the Screen


func on_selected():
	Signals.golden_apple_eaten.connect(collect_everything)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)


func collect_everything(a):
	var sleep_time = 0.1
	for apple in ApplesList.get_children():
		if apple:
			apple.is_attracted = true
			await get_tree().create_timer(sleep_time).timeout
			sleep_time = max(0.001, sleep_time * 0.95)
		

func get_text()->String:
	return "Sometimes spawn Golden Apples... What could they do ? "
