extends Upgrade

var add_amount = 3

func on_selected():
	SnakeProps.min_juice_combo += add_amount
	print("Added +%d to min juice combo. Current min juice combo : " % [add_amount], SnakeProps.min_juice_combo)

func get_text()->String:
	return "Gives +%d to your starting Juice Combo ! %d -> %d" % \
	 [add_amount, SnakeProps.min_juice_combo, SnakeProps.min_juice_combo + add_amount]
