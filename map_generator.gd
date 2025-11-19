extends Node

@export var height: int
@export var width: int
@export var nb_rectangles: int
@export var min_side: int
@export var max_side: int
var level = 0
var tot_free_space = 0
var side_range: int
@export var tunnels_per_rectangle: int

var middle: Vector2i

var map: Array[Array]
var rectangles: Array[Rectangle] = []

func print_map():
	for i in range(height):
		var s = ''
		for j in range(width):
			if map[i][j]:
				s += 'X'
			else:
				s += '.'
		print(s)


func fill_map():
	for i in range(height):
		map.append([])
		for _j in range(width):
			map[i].append(false)

func add_spawn_rectangle():
	Rectangle.new(self, 30, 20, Vector2i(0,0))
	
	
func add_random_rectangles():
	for _i in range(nb_rectangles):
		var h = min_side + (randi() % side_range)
		var w = min_side + (randi() % side_range)
		var pos = Vector2i(randi() % (height - h),randi() % (width - w))
		Rectangle.new(self, h, w, pos)


func is_path_finished(curr_path, pos, curr_rectangle: Rectangle):
	return (pos.x <= 0 or pos.x >= height or pos.y <= 0 or pos.y >= width) or \
		((map[pos.x][pos.y] and not curr_rectangle.is_inside(pos)) and \
			not curr_path.has(pos))
		
	
	
func create_one_tunnel(rec: Rectangle, target_rec: Rectangle):
	var target: Vector2i = target_rec.middle()
	var curr: Vector2i = rec.start + Vector2i(randi() % rec.x,randi() % rec.y)
	var last: Vector2i  = Vector2i(-1,-1)
	var curr_path: Dictionary = {}
	while not is_path_finished(curr_path, curr, rec):
		curr_path[curr] = null
		map[curr.x][curr.y] = true
		if last != Vector2i(-1,-1):
			var curr_to_last = Direction.dir_to_vec(Direction.cells_to_dir(curr, last))
			map[curr.x + curr_to_last.y][curr.y + curr_to_last.x] = true
		
		var vec_towards = Utils.unit_vec(target - curr)
		if vec_towards.length() == 0: # Vector2i(0,0)
			return
		if vec_towards.x != 0 and vec_towards.y != 0:
			if randi() % 2 == 1: vec_towards.x = 0 
			else: vec_towards.y = 0 
		var dir = Direction.vec_to_dir(vec_towards)
		#var random_dir: Direction.DIR = Direction.get_random_direction()
		#if curr + Direction.dir_to_vec(random_dir) == last:
			#random_dir = Direction.opp(random_dir)
		last = curr
		curr = curr + Direction.dir_to_vec(dir)
	
	
func add_tunnels():
	for rec in rectangles:
		for i in range(tunnels_per_rectangle):
			create_one_tunnel(rec, rectangles.pick_random())
	
	
func generate_map() -> Array[Array]:
	fill_map()
	#add_random_rectangles()
	#add_tunnels()
	return map
	

func _ready():
	SnakeProps.MapGenerator = self
	
	side_range = max_side - min_side
	middle = Vector2i(height / 2, width / 2)
	generate_map()
	

func try_update_map():
	if len(SnakeProps.SM.body) > 0.7 * tot_free_space:
		level_up_map()
	

func level_up_map():
	level += 1
	update_from_level()

func outline_rectangle(r: Rectangle, outline: int) -> Rectangle:
	return Rectangle.new(self, r.x+ 2*outline, r.y + 2*outline, r.start - Vector2i(outline, outline))

func is_border_wall(pos : Vector2i) -> bool:
	for i in range(-1,2):
		for j in range(-1,2):
			var neigh : Vector2i = pos + Vector2i(i,j)
			if ! SnakeProps.EnvironmentManager.is_wall(neigh) : 
				# If any neighbour is floor then we are border
				return true
	# All neighbours are wall
	return false

func nearest_floor(pos : Vector2i) -> Vector2i:
	for dir in Direction.get_all_directions():
		var neigh : Vector2i = pos + Direction.dir_to_vec(dir)
		if !SnakeProps.EnvironmentManager.is_wall(neigh):
			return neigh
	return Vector2i(0,0)
	
func map_border() -> Array[Vector2i]:
	var start = Vector2i(-144, 0)
	while SnakeProps.EnvironmentManager.is_wall(start):
		start += Vector2i(1,0)
	start -= Vector2i(1,0) #set on wall
	var visited = {start: 1}
	var queue: Array[Vector2i] = [start]
	var border: Array[Vector2i] = [start]
	while len(queue) > 0:
		var elt : Vector2i = queue.pop_front()
		for dir in Direction.get_all_directions():
			var neigh : Vector2i = elt + Direction.dir_to_vec(dir)
			if visited.has(neigh) : continue
			visited[neigh] = 1
			if ! SnakeProps.EnvironmentManager.is_wall(neigh) : continue
			if ! is_border_wall(neigh) : continue
			border.append(neigh)
			queue.append(neigh)
	return border
	
func outline_everything(outline: int):
	var dup =  rectangles.duplicate()
	tot_free_space = 0
	rectangles = []
	for r in dup:
		outline_rectangle(r, outline)
	
func get_biggest_rectangle():
	var min_x = 99999
	var min_y = 99999
	var max_x = -99999
	var max_y = -99999
	for r in rectangles:
		min_x = min(min_x, r.start.x)
		min_y = min(min_y, r.start.y)
		max_x = max(max_x, r.start.x + r.x)
		max_y = max(max_y, r.start.y + r.y)
	Rectangle.new(self, max_x - min_x, max_y - min_y, Vector2i(min_x,min_y))
	
func generate_random_corridor():
	var nb_tries = 20
	var max_corridor_length = 50
	for i in range(nb_tries):
		var start = map_border().pick_random()
		while nearest_floor(start) == Vector2i(0,0):
			start = map_border().pick_random()
		var dir:Direction.DIR = Direction.cells_to_dir(nearest_floor(start), start)
		var vec_dir = Direction.dir_to_vec(dir)
		for j in range(max_corridor_length):
			var pos = start + j * vec_dir
			if ! SnakeProps.EnvironmentManager.is_wall(pos):
				Rectangle.new(self,(j*vec_dir).x, (j*vec_dir).y, start)
				print("generated random corridor at", start)
				return
	print("failed to generate corridor")
	return				
				
func generate_room(is_corridor : bool = false):
	var start = map_border().pick_random()
	while nearest_floor(start) == Vector2i(0,0):
		start = map_border().pick_random()
	var dir:Direction.DIR = Direction.cells_to_dir(nearest_floor(start), start)
	var vec_dir = Direction.dir_to_vec(dir)
	# Generate the corridor
	var v = 15 * vec_dir + Vector2i(1,1)
	Rectangle.new(self, v.x, v.y, start)
	
	# Generate the room
	var arrival = start + v
	var perp_dir_vector = Vector2i(vec_dir.y, vec_dir.x)
	# Random Data for the room
	var dim_1_size = randi() % 20 + 3
	var dim_2_size = randi() % 20 + 3
	var offset = randi() % dim_2_size
	var base : Vector2i = vec_dir * dim_1_size 
	var other_dim = perp_dir_vector * dim_2_size
	var r_vec = base + other_dim
	var r = Rectangle.new(self, r_vec.x, r_vec.y, arrival + perp_dir_vector * -offset)
	
	var basket = preload("res://scenes/apples_basket.tscn").instantiate()
	var tile_pos = Vector2(r.start) + Vector2(r.x, r.y)/2
	basket.position = SnakeProps.GameTiles.tile_pos_to_global_pos(tile_pos)
	print(tile_pos, "  ", basket.position)
	SnakeProps.ApplesList.add_child(basket)
	
func update_from_level():
	if level == 1:
		Rectangle.new(self, 20,12, Vector2i(0,0))
	else:
		Signals.map_updated.emit()
		outline_everything(1)
		generate_random_corridor()
		generate_random_corridor()
		generate_room()
		generate_room()
		generate_room()
		%MainCam.start_shake(40, 2)
	return
