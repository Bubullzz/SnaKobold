extends Upgrade

func _ready():
	title = "Super Spiller"
	
func on_selected():
	SnakeProps.max_allowed_misses += 1
	print("Allowed one additional Juice miss.\nCurrently : %d" % [SnakeProps.max_allowed_misses])

func get_text()->String:
	return "Allows one additional Juice miss.\n Currently : %d" % \
	 [SnakeProps.max_allowed_misses]
