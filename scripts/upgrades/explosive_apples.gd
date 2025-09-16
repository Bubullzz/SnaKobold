extends Upgrade

@export var UpgradesComponent: Node2D
var activated = false 
var add_amount = 3


func on_apple_eaten(apple):
	print("ayo")
	print(apple.tiles_pos)
	SnakeProps.eatables_pos.erase(apple.tiles_pos)
	for i in range(-1,2):
		for j in range(-1,2):
			if i == 0 and j == 0:
				continue
			if SnakeProps.eatables_pos.has(apple.tiles_pos + Vector2i(i,j)) and SnakeProps.eatables_pos[apple.tiles_pos + Vector2i(i,j)] is Apple:
				SnakeProps.eatables_pos[apple.tiles_pos + Vector2i(i,j)].collect(self)

func on_selected():
	activated = true
	Signals.apple_eaten.connect(on_apple_eaten)

func get_text()->String:
	return "Apples explode and collect all the other apples Around !"
