extends Node

# Define the class with static methods and properties
class_name Direction

# Define the DIR enum
enum DIR { UP, DOWN, LEFT, RIGHT }

static func pretty_print(dir: DIR)-> String:
	match dir:
		Direction.DIR.UP: return "UP"
		Direction.DIR.DOWN: return "DOWN"
		Direction.DIR.LEFT: return "LEFT"
		Direction.DIR.RIGHT: return "RIGHT"
	return "ERROR"
	
static func get_all_directions():
	return [Direction.DIR.UP, Direction.DIR.DOWN, Direction.DIR.LEFT, Direction.DIR.RIGHT]


static func get_random_direction():
	return get_all_directions()[randi() % 4]
	

static func opp(dir):
	match dir:
		Direction.DIR.UP: return Direction.DIR.DOWN
		Direction.DIR.DOWN: return Direction.DIR.UP
		Direction.DIR.LEFT: return Direction.DIR.RIGHT
		Direction.DIR.RIGHT: return Direction.DIR.LEFT


static func cells_to_dir(c1,c2) -> Direction.DIR:
	# Direction to go from c1 to c2
	match c2 - c1:
		Vector2i(0,-1): return Direction.DIR.UP
		Vector2i(0,1): return Direction.DIR.DOWN
		Vector2i(-1,0): return Direction.DIR.LEFT
		Vector2i(1,0): return Direction.DIR.RIGHT
		_: push_error("Error when getting Direction")
	return Direction.DIR.UP

static func dir_to_vec(dir)-> Vector2i:
	var dict = {
	DIR.UP : Vector2i(0,-1),
	DIR.DOWN : Vector2i(0,1),
	DIR.LEFT : Vector2i(-1,0),
	DIR.RIGHT : Vector2i(1,0)
	}
	return dict[dir]


static func vec_to_dir(vec: Vector2i):
	var dict = {
	DIR.UP : Vector2i(0,-1),
	DIR.DOWN : Vector2i(0,1),
	DIR.LEFT : Vector2i(-1,0),
	DIR.RIGHT : Vector2i(1,0)
	}
	var dict2 = Utils.reverse_dict(dict)
	return dict2[vec]
	
	
static func hor(dir):
	match dir:
		Direction.DIR.LEFT: return -1
		Direction.DIR.RIGHT: return 1
	return 0

static func ver(dir):
	match dir:
		Direction.DIR.UP: return -1
		Direction.DIR.DOWN: return 1
	return 0

static func angle_rot(dir):
	match dir:
		Direction.DIR.UP: return 0
		Direction.DIR.DOWN: return 180
		Direction.DIR.LEFT: return -90
		Direction.DIR.RIGHT: return 90
	return 0
