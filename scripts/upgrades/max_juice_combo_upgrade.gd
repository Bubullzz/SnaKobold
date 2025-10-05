extends Upgrade

var add_amount = 5

func _ready():
	title = "Hyper Combo"
	
func on_selected():
	SnakeProps.max_juice_combo += add_amount
	print("Added +%d to max juice combo.\nCurrent max juice combo : " % [add_amount], SnakeProps.max_juice_combo)

func get_text()->String:
	return "Gives +%d to your max Juice Combo !\n %d -> %d" % \
	 [add_amount, SnakeProps.max_juice_combo, SnakeProps.max_juice_combo + add_amount]
