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


func outline_everything(outline: int):
	var dup =  rectangles.duplicate()
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
	
func update_from_level():
	for r in rectangles:
		print(r.x, r.y, r.start)
		print()
	outline_everything(1)
	for r in rectangles:
		print(r.x, r.y, r.start)
		print()
	if level == 1:
		Rectangle.new(self, 30,20, Vector2i(0,0))
		
	if level == 2:
		print("here")
		Rectangle.new(self, 30, 15, Vector2i(15,25))
		Rectangle.new(self, 1, 5, Vector2i(20,20))
		Rectangle.new(self, 1, 5, Vector2i(29,20))
	if level == 3:
		Rectangle.new(self, -25, -30, Vector2i(60,20))
		Rectangle.new(self, 5, 1, Vector2i(30,3))
		Rectangle.new(self, 1, 5, Vector2i(40,20))
	if level == 4:
		#get_biggest_rectangle()
		SnakeProps.SM.target_speed = 3.
		SnakeProps.SM.speed = 3.
	if level == 5:
		Rectangle.new(self, 60, 65, Vector2i(85,5))
		Rectangle.new(self, -25, 1, Vector2i(85,10))
		Rectangle.new(self, -25, 1, Vector2i(85,25))
		Rectangle.new(self, -25, 1, Vector2i(85,42))
	if level == 6:
		Rectangle.new(self, 110, 25, Vector2i(-40,50))
		Rectangle.new(self, 1, -10, Vector2i(55,50))
		Rectangle.new(self, 1, -10, Vector2i(55,50))
		Rectangle.new(self, 1, -10, Vector2i(5,50))
		Rectangle.new(self, -25, 1, Vector2i(85,65))
	if level == 7:
		#ijget_biggest_rectangle()
		SnakeProps.SM.target_speed = 4.
		SnakeProps.SM.speed = 4.
	
		
		
		
		
