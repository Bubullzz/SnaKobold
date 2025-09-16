extends Upgrade

@export var UpgradesComponent: Node2D
var activated = false 
var add_amount = 3


func on_apple_eaten(apple):
	print("ayo")
	print(apple.position)
	for i in range(-1,2):
		for j in range(-1,2):
			pass

func on_selected():
	activated = true
	Signals.apple_eaten.connect(on_apple_eaten)

func get_text()->String:
	return "Apples explode and collect all the other apples Around !"
