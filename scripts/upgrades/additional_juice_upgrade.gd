extends Upgrade

func _ready():
	title = "Turbo Drinker"
	
func on_selected():
	Juice.instantiate(SnakeProps.SM, SnakeProps.SM.body[0])

func get_text()->String:
	return "Spawns an additionnal juice !" 
