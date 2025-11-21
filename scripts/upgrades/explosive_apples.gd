extends Upgrade

@export var UpgradesComponent: Node2D
var activated = false 
var add_amount = 3
var running = false
func _ready():
	title = "Applomancer"
	
func start_particles(pos: Vector2i):
	var p = $Part.duplicate()
	p.position = SnakeProps.GameTiles.tile_pos_to_global_pos(pos)
	p.get_child(0).emitting = true
	get_tree().root.add_child(p)

	
func rec_apple_find(apple: Apple, visited: Dictionary, apples: Array[Apple]):
	var pos = apple.tiles_pos
	for i in range(-1,2):
		for j in range(-1,2):
			if i == 0 and j == 0:
				continue
			var neigh_pos = pos + Vector2i(i,j)
			if visited.has(neigh_pos): continue
			visited[neigh_pos] = 1
			if SnakeProps.eatables_pos.has(neigh_pos) \
				and SnakeProps.eatables_pos[neigh_pos] != null \
				and SnakeProps.eatables_pos[neigh_pos] is Apple:
					
				apples.append(SnakeProps.eatables_pos[neigh_pos])
				rec_apple_find(SnakeProps.eatables_pos[neigh_pos], visited, apples)
			else:
				print("problem")
	
func on_apple_eaten(apple: Apple):
	if !running:
		running = true
		var pos = apple.tiles_pos
		var apples: Array[Apple] = []
		var visited: Dictionary = {}
		rec_apple_find(apple, visited, apples)

		#await get_tree().create_timer(.2).timeout
		if len(apples) > 0:
			$Cooldown.start()
			start_particles(pos)
			for a in apples:
				if a: 
					a.collect()
					await get_tree().create_timer(.01).timeout
		running = false
		

func on_selected():
	print("Selected AppleoMancer")

	activated = true
	Signals.apple_eaten.connect(on_apple_eaten)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)

func get_text()->String:
	return "Apples explode and collect all the other apples around"
