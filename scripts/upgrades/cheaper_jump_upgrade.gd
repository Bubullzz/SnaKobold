extends Upgrade

var percentage_reduction = .2
var level = 0
func _ready():
	title = "Athlete"
	
func on_selected():
	print("Selected Athlete Upgrade")

	level += 1
	if level == 1:
		SnakeProps.jump_price = SnakeProps.BASE_JUMP_PRICE
		return
	
	SnakeProps.jump_price *= 1 - percentage_reduction

func get_text()->String:
	if level == 0:
		return "You can now Jump over your body for 500 Juice !"
	return "Reduces Jump Price !\n %d -> %d" % \
	 [SnakeProps.jump_price, SnakeProps.jump_price * (1 - percentage_reduction)]
