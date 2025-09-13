extends Node

class_name Rectangle

var x: int
var y: int 
var start: Vector2i

func _init(MapGenerator, _x, _y, _start: Vector2i):
	x = _x
	y = _y
	start = _start
	for i in range(x):
		for j in range(y):
			MapGenerator.map[start.x + i][start.y + j] = true
	
	MapGenerator.rectangles.append(self)
