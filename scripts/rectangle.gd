extends Node

class_name Rectangle

var x: int
var y: int 
var start: Vector2i


func middle()-> Vector2i:
	return start + Vector2i(x/2, y/2)


func is_inside(pos)-> bool:
	return pos.x >= start.x and pos.x < start.x + x and pos.y >= start.y and pos.y < start.y + y


func _init(MapGenerator, _x, _y, _start: Vector2i):
	x = _x
	y = _y
	start = _start
	for i in range(x):
		for j in range(y):
			MapGenerator.map[start.x + i][start.y + j] = true
			SnakeProps.EnvironmentManager.remove_wall(Vector2i(start.x + i, start.y + j))
	
	var to_update : Array[Vector2i] = []
	for i in range(_x):
		to_update.append(_start + Vector2i(i, -1))
		to_update.append(_start + Vector2i(i, _y + 1))
	
	for i in range(_y):
		to_update.append(_start + Vector2i(-1, i))
		to_update.append(_start + Vector2i(_x + 1, i))
	
	SnakeProps.EnvironmentManager.update_terrain_cells(to_update)
	MapGenerator.rectangles.append(self)
