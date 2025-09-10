extends Upgrade

@export var ApplesList: Node #Node containing all the Apples on the Screen

func on_selected():
	var sleep_time = 0.1
	for apple in ApplesList.get_children():
		if apple:
			apple.is_attracted = true
			await get_tree().create_timer(sleep_time).timeout
			sleep_time = max(0.001, sleep_time * 0.95)
		

func get_text()->String:
	return "Collects ALL the apples on the Map !!!!!!"
