extends Upgrade

var add_amount = 2

func _ready():
	title = "Renforcement Juicing"
	
func on_selected():
	SnakeProps.base_juice_wait_time += add_amount
	print("Added +%d to max juice combo.\nCurrent max juice combo : " % [add_amount], SnakeProps.max_juice_combo)

func get_text()->String:
	return "Juice takes +%d more seconds to spill !\n %ds -> %ds" % \
	 [add_amount, SnakeProps.base_juice_wait_time, SnakeProps.base_juice_wait_time + add_amount]
