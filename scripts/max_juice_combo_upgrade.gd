extends Upgrade

var add_amount = 3

func _init():
	text = "Gives +%d to your max Juice Combo" % [add_amount]

func on_selected():
	SnakeProps.max_juice_combo += add_amount
	print("Added +%d to max juice combo. Current max juice combo : " % [add_amount], SnakeProps.max_juice_combo)
