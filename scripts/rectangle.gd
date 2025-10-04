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
	if x < 0:
		start += Vector2i(x, 0)
		x = -x
	if y < 0:
		start += Vector2i(0, y)
		y = -y
		
	for i in range(x):
		for j in range(y):
			SnakeProps.EnvironmentManager.remove_wall(Vector2i(start.x + i, start.y + j))
	
	var to_update : Array[Vector2i] = []
	for i in range(x):
		to_update.append(start + Vector2i(i, -1))
		to_update.append(start + Vector2i(i, y + 1))
	
	for i in range(y):
		to_update.append(start + Vector2i(-1, i))
		to_update.append(start + Vector2i(x + 1, i))
	
	SnakeProps.EnvironmentManager.update_terrain_cells(to_update)
	MapGenerator.rectangles.append(self)
	MapGenerator.tot_free_space += x * y
