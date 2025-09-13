extends Node

@export var height: int
@export var width: int

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

func generate_map() -> Array[Array]:
	fill_map()
	Rectangle.new(self, 15, 15, middle - Vector2i(8,8))
	return map
	

func _ready():
	middle = Vector2i(height / 2, width / 2)
	generate_map()
	print_map()
	
	
