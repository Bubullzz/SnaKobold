extends Node

@export var height: int
@export var width: int
@export var nb_rectangles: int
@export var min_side: int
@export var max_side: int
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
	Rectangle.new(self, 15, 15, middle - Vector2i(8,8))
	
	
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
	add_spawn_rectangle()
	add_random_rectangles()
	add_tunnels()
	return map
	

func _ready():
	side_range = max_side - min_side
	middle = Vector2i(height / 2, width / 2)
	generate_map()
	
	
