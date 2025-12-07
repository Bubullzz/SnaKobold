extends Node2D

func _process(_delta):
	var SM = get_parent().get_node("%SnakeManager")
	var MAP = get_parent().get_node("%WallsLayer")

	var tail_dir = Direction.cells_to_dir(SM.body[SM.body.size() - 2], SM.body[SM.body.size() - 1])
	var tail_pos = MAP.map_to_local(SM.body[SM.body.size() - 1])
	$Part.rotation_degrees = Direction.angle_rot(tail_dir)
	position = tail_pos
	if SnakeProps.growth > 0:
		$Part.emitting = false
	else:
		$Part.emitting = true

func stop():
	$Part.emitting = false
