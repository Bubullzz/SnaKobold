extends Upgrade

@export var ApplesList: Node #Node containing all the Apples on the Screen

func _ready():
	title = "8 Gold Ingot and an Apple"

func on_selected():
	print("Selected Golden Apples Spawn Upgrade")

	Signals.golden_apple_eaten.connect(collect_everything)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)


func collect_everything(_a): # a is needed there because emitted signal has one parameter
	var sleep_time = 0.1
	for apple in ApplesList.get_children():
		if apple and apple is Apple:
			apple.is_attracted = true
			await get_tree().create_timer(sleep_time).timeout
			sleep_time = max(0.001, sleep_time * 0.95)
		

func get_text()->String:
	return "Sometimes spawn Golden Apples... What could they do ? "
