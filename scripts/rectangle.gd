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
	
	MapGenerator.rectangles.append(self)
