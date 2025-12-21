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
	SnakeProps.Overlays.add_child(p)

	
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

func iter_apple_find(start: Apple)-> Array[Array]:
	var full_array: Array[Array] = []
	var curr_list = []
	var stack: Array[Apple] = [start, null]
	var visited: Dictionary = {}
	while len(stack) > 1: # Stop when stack is just a null
		var curr: Apple = stack.pop_front()
		if curr == null: # On a flag, we did all of the n-th ring
			stack.append(null)
			full_array.append(curr_list)
			curr_list = [] # Might be buggy bc of reference stuff
		else: 
			for i in range(-1,2):
				for j in range(-1,2):
					var neigh_pos = curr.tiles_pos + Vector2i(i,j)
					if (i == 0 and j == 0) or visited.has(neigh_pos):
						continue
					visited[neigh_pos] = 1
					if SnakeProps.eatables_pos.has(neigh_pos) \
					and SnakeProps.eatables_pos[neigh_pos] != null \
					and SnakeProps.eatables_pos[neigh_pos] is Apple:
						stack.append(SnakeProps.eatables_pos[neigh_pos])
						curr_list.append(SnakeProps.eatables_pos[neigh_pos])
	
	return full_array
	
	
	
func on_apple_eaten(apple: Apple):
	if !running:
		running = true
		var tot_time = .2
		var full_array = iter_apple_find(apple)
		$Cooldown.start()
		await get_tree().create_timer(.1).timeout
		for level in full_array:
			level.shuffle()
			for a in level:
				if a: 
					start_particles(a.tiles_pos)
					a.collect()
					await get_tree().create_timer(.005).timeout
				$Cooldown.start()
			await get_tree().create_timer(tot_time / len(full_array)).timeout
		running = false
		return

func on_selected():
	print("Selected AppleoMancer")

	activated = true
	Signals.apple_eaten.connect(on_apple_eaten)
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)

func get_text()->String:
	return "Apples explode and collect all the other apples around"
