extends Upgrade

@export var UpgradesComponent: Node2D
var activated = false 
var add_amount = 3

func start_particles(pos: Vector2i):
	var p = $Part.duplicate()
	p.position = SnakeProps.GameTiles.tile_pos_to_global_pos(pos)
	p.get_child(0).emitting = true
	get_tree().root.add_child(p)

	
func on_apple_eaten(apple: Apple):
	SnakeProps.eatables_pos.erase(apple.tiles_pos)
	var pos = apple.tiles_pos
	var around = []
	for i in range(-1,2):
		for j in range(-1,2):
			if i == 0 and j == 0:
				continue
			if SnakeProps.eatables_pos.has(apple.tiles_pos + Vector2i(i,j)) and SnakeProps.eatables_pos[apple.tiles_pos + Vector2i(i,j)] is Apple:
				around.append(SnakeProps.eatables_pos[apple.tiles_pos + Vector2i(i,j)])
	around.shuffle()
	await get_tree().create_timer(.2).timeout
	start_particles(pos)
	for a in around:
		if a: 
			a.collect()
		

func on_selected():
	activated = true
	Signals.apple_eaten.connect(on_apple_eaten)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)

func get_text()->String:
	return "Apples explode and collect all the other apples Around !"
