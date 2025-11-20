extends Upgrade

func _ready():
	title = "Demultiplacation"
	
func on_selected():
	print("Spawned an additional juice")

	var i = Juice.instantiate(SnakeProps.SM, SnakeProps.SM.body[0])
	call_deferred("play", i)

func get_text()->String:
	return "Spawns an additionnal juice" 
