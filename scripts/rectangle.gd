extends Node

class_name Rectangle

const DustParticles = preload("res://particles/dust_particles.tscn")
var x: int
var y: int 
var start: Vector2i


func middle()-> Vector2i:
	return start + Vector2i(x/2, y/2)


func is_inside(pos)-> bool:
	return pos.x >= start.x and pos.x < start.x + x and pos.y >= start.y and pos.y < start.y + y

static func async_actions(rec: Rectangle):
	# Get any walls that will get removed and needs particles on it
	var walls_to_remove = []
	for i in range(rec.x+1):
		for j in range(rec.y+1):
			var v = Vector2i(rec.start.x + i, rec.start.y + j)
			if SnakeProps.EnvironmentManager.is_wall(v):
				walls_to_remove.append(v)
	
	var to_update : Array[Vector2i] = []
	for i in range(rec.x+1):
		to_update.append(rec.start + Vector2i(i, -1))
		to_update.append(rec.start + Vector2i(i, rec.y + 1))
	
	for i in range(rec.y+1):
		to_update.append(rec.start + Vector2i(-1, i))
		to_update.append(rec.start + Vector2i(rec.x + 1, i))
	
	# Only keep what we actually need to update
	var l : Array[Vector2i] = []
	for cell in to_update:
		if SnakeProps.EnvironmentManager.is_wall(cell):
			l.append(cell)
	to_update = l
	
	var dust_time = 2
	for cell in walls_to_remove:
		var inst = DustParticles.instantiate()
		inst.position = SnakeProps.GameTiles.tile_pos_to_global_pos(cell)
		SnakeProps.GameTiles.add_child(inst)
		inst.start()
		inst.scale *= 1
	
	await SnakeProps.get_tree().create_timer(dust_time/2).timeout 

	for cell in walls_to_remove:
		SnakeProps.EnvironmentManager.remove_wall(cell)

	SnakeProps.EnvironmentManager.update_terrain_cells(to_update)
	
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
		
	async_actions(self)

	MapGenerator.rectangles.append(self)
	MapGenerator.tot_free_space += x * y
