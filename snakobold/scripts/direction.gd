extends Node

# Define the class with static methods and properties
class_name Direction

# Define the DIR enum
enum DIR { UP, DOWN, LEFT, RIGHT }

static func opp(dir):
    match dir:
        Direction.DIR.UP: return Direction.DIR.DOWN
        Direction.DIR.DOWN: return Direction.DIR.UP
        Direction.DIR.LEFT: return Direction.DIR.RIGHT
        Direction.DIR.RIGHT: return Direction.DIR.LEFT


static func cells_to_dir(c1,c2) -> Direction.DIR:
    # Direction to go from c1 to c2
    match c2 - c1:
        Vector2(0,-1): return Direction.DIR.UP
        Vector2(0,1): return Direction.DIR.DOWN
        Vector2(-1,0): return Direction.DIR.LEFT
        Vector2(1,0): return Direction.DIR.RIGHT
        _: push_error("Error when getting Direction")
    return Direction.DIR.UP

static func dir_to_vec(dir):
    var dict = {
    DIR.UP : Vector2(0,-1), 
    DIR.DOWN : Vector2(0,1), 
    DIR.LEFT : Vector2(-1,0), 
    DIR.RIGHT : Vector2(1,0) 
    }
    return dict[dir]