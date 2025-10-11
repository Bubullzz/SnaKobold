extends Upgrade

var amount = 10.
var growth_factor = 10.
var times_selected = 0

func _ready():
	title = "Juicy Apples"
	
func on_selected():
	times_selected += 1
	if times_selected >= 2:
		amount+=growth_factor
	else:
		Signals.apple_eaten.connect(apple_eaten)

func get_text()->String:
	if times_selected == 0:
		return "Eating an apple gives you juice proportional to your combo"
	else:
		return "Increases the amount of juice you get by eating apples\n%d%% -> %d%%" % [amount, amount+growth_factor]

func apple_eaten(_apple):
	SnakeProps.update_juice(SnakeProps.juice_combo * 100 * (amount / 100))
