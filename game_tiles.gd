extends Node

func _ready():
	SnakeProps.GameTiles = self


func tile_pos_to_global_pos(vec: Vector2i) -> Vector2:
	return %WallsLayer.map_to_local(vec)
