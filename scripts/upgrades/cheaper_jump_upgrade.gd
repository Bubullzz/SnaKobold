extends Upgrade

var percentage_reduction = .2

func _ready():
	title = "Athlete"
	
func on_selected():
	SnakeProps.jump_price *= 1 - percentage_reduction

func get_text()->String:
	return "Reduces Jump Price !\n %d -> %d" % \
	 [SnakeProps.jump_price, SnakeProps.jump_price * (1 - percentage_reduction)]
