extends Node

enum BODY_PART {HEAD, PRE_HEAD, BODY, PRE_TAIL, TAIL}
var GROUND_ID = 1
var JUMP_ID = 1 
var APPLE_ID = 1
var JUICE_ID = 0
var HEAD_BASE = Vector2i(0,0)
var TAIL_BASE = Vector2i(0,1)
var PRE_HEAD_BASE = Vector2i(0,2)
var PRE_TAIL_BASE = Vector2i(0,6)
var VERT_BODY = Vector2i(3,2) # Used when passing under body because of jump

var dir_buffer = [null, null] 
var jumping_frame = false

# All snake pos in the TileMap
var body : Array[Vector2i] = []
var curr_dir : Direction.DIR = Direction.DIR.RIGHT
var clock : int = 0 # The clock used for updating the snake. One pixel per tick
var clock_collector : float = 0.0
var actual_speed = SnakeProps.target_speed


func is_snake(pos):
	return %SnakeLayer.get_cell_source_id(pos) == GROUND_ID || %snakeJumpingLayer.get_cell_source_id(pos) == JUMP_ID


func is_ground_snake(pos):
	return %SnakeLayer.get_cell_source_id(pos) == GROUND_ID


func is_jump_snake(pos):
	return %snakeJumpingLayer.get_cell_source_id(pos) == JUMP_ID


func is_free(pos):
	return %SnakeLayer.get_cell_source_id(pos) == -1 && %snakeJumpingLayer.get_cell_source_id(pos) == -1 && !%EnvironmentManager.is_wall(pos)


func get_body_index(pos: Vector2i) -> int:
	var i = 0
	while i < len(body):
		if body[i] == pos:
			return i
		var _diff : Vector2i = abs(body[i] - pos)
		i += 1 #diff.x + diff.y
	return -1
	

func check_accessible(pos):
	var sum = 0
	for dir in [Direction.DIR.UP, Direction.DIR.DOWN, Direction.DIR.LEFT, Direction.DIR.RIGHT]:
		if %EnvironmentManager.is_wall(pos + Direction.dir_to_vec(dir)):
			sum += 1
	return sum < 3


func place_snake(pos):
	for i in range(4):
		body.push_back(pos + Direction.dir_to_vec(Direction.DIR.LEFT) * i)
		%SnakeLayer.set_cell(body[-1], GROUND_ID, Vector2i(0, 0))


func dir_buff_add(dir):
	if dir_buffer[0] == null:
		dir_buffer[0] = dir
	else: dir_buffer[1] = dir


func dir_buff_consume():
	var tmp = dir_buffer[0]
	dir_buffer[0] = dir_buffer[1]
	dir_buffer[1] = null
	return tmp


func dir_to_atlas_transform(dir : Direction.DIR) -> int:
	# Uses Atlas transforms flags (godot hardcode) for mirror and/or flip
	match dir:
		Direction.DIR.UP:
			return 0
		Direction.DIR.DOWN:
			return 1 << 13 
		Direction.DIR.LEFT:
			return 1 << 14 | 1 << 13
		Direction.DIR.RIGHT:
			return  1 << 14 | 1 << 13 | 1 << 12
		_:
			push_error("Invalid direction")
			return -1


func pop_tail():
	var old_tail_co = body.pop_back()
	if %snakeJumpingLayer.get_cell_source_id(old_tail_co) == (JUMP_ID):
		%snakeJumpingLayer.set_cell(old_tail_co)
		if ! %EnvironmentManager.is_wall(old_tail_co): # If not in wall then the tail is passing under body and needs update
			var index = get_body_index(old_tail_co)
			if index == -1:
				print("Error: Tail not found in body")
				return
			var pre_dir = Direction.cells_to_dir(body[index + 1], body[index])
			var post_dir = Direction.cells_to_dir(body[index], body[index - 1])
			if index == 0: # we just jumped, on the tail weird but happens
				post_dir = curr_dir
			if pre_dir == post_dir: # Going straight
				%SnakeLayer.set_cell(body[index], GROUND_ID, PRE_HEAD_BASE + Vector2i(3, 0), dir_to_atlas_transform(pre_dir))
			else: # Turning
				var base_pos = PRE_HEAD_BASE # Where do we begin the table in the sprites sheet
				var pre_head = base_pos + Vector2i(int(post_dir) * 4, int(pre_dir)) # start on top left of table then select right line and col using order up, down, left, right
				%SnakeLayer.set_cell(body[1], GROUND_ID, pre_head + Vector2i(3, 0)) # Here we put 4 because we want the sprite at end of animation

	else:
		%SnakeLayer.set_cell(old_tail_co)


func handle_collision():
	var real_coor_hit_pos = %SnakeLayer.map_to_local(body[0])
	%Boom.set_position(real_coor_hit_pos)
	%Boom.set_emitting(true)
	SnakeProps.health_points -= 1
	var send_back_amaount = 2
	while send_back_amaount > 0 or %snakeJumpingLayer.get_cell_source_id(body[0]) == JUMP_ID: # Pop until we reach a non-jumping cell
		var poped = body.pop_front()
		if %snakeJumpingLayer.get_cell_source_id(poped) == JUMP_ID:
			%snakeJumpingLayer.set_cell(poped)
		else:
			%SnakeLayer.set_cell(poped)
		send_back_amaount -= 1
	actual_speed = 0.1
	curr_dir = Direction.cells_to_dir(body[1], body[0])
	var ideal_cam_pos = body[0] + 1 * Direction.dir_to_vec(Direction.opp(curr_dir))
	%MainCam.set_tmp_scene(%SnakeLayer.map_to_local(ideal_cam_pos), 6, 1, 4.)
	%MainCam.start_shake()

	dir_buffer = [null, null]

	SnakeProps.update_max_juice() # makes juice bar smaller, based on lost size
	SnakeProps.update_juice(0) 
	%SnakeAdditionnalVisuals.clear_additional_visuals()

func check_not_waisting(pos) -> bool:
	# Check if we are not wating all juice to do 12 jumps in wall then die
	# also accidentaly check if we can jump at all
	var i = 0
	while i * SnakeProps.jump_price <= SnakeProps.juice:
		if is_free(pos + Direction.dir_to_vec(curr_dir) * i):
			return true
		if %EnvironmentManager.is_wall(pos + Direction.dir_to_vec(curr_dir) * i): # or is_jump_snake(pos + Direction.dir_to_vec(curr_dir) * i):
			return false
		i += 1
	return false


func step(jumped_last_frame : bool):
	# needs to be done first 
	if SnakeProps.growth == 0:
		pop_tail()
	# Update Direction from inputs in the last X frame
	if ! jumped_last_frame: # dont turn when jumping
		var d = dir_buff_consume()
		if Direction.opp(d) == curr_dir || d == curr_dir:
			d = dir_buff_consume()
		if d != null && Direction.opp(d) != curr_dir:
			curr_dir = d

	# Update body data
	var expected_head_pos = body[0] + Direction.dir_to_vec(curr_dir)
	if is_snake(expected_head_pos) || %EnvironmentManager.is_wall(expected_head_pos):
		if ! is_jump_snake(expected_head_pos) && check_not_waisting(expected_head_pos): # && juice > jump_price // this may solve bug
			jumping_frame = true
			body.push_front(expected_head_pos) 
			SnakeProps.update_juice(-SnakeProps.jump_price)
		else:
			handle_collision()
	else:
		body.push_front(expected_head_pos)

	# needs to be done after updated body 
	SnakeProps.growing()

	%SnakeHeadCollision.set_position(%SnakeLayer.map_to_local(body[0]))


func update_pre_head_sp() -> void :
	var pre_dir = Direction.cells_to_dir(body[2], body[1])
	var post_dir = Direction.cells_to_dir(body[1], body[0])
	if pre_dir == post_dir: # Going straight
		var layer
		var sprite_id
		if %snakeJumpingLayer.get_cell_source_id(body[1]) == JUMP_ID:
			layer = %snakeJumpingLayer
			sprite_id = JUMP_ID
		else:
			layer = %SnakeLayer
			sprite_id = GROUND_ID
		layer.set_cell(body[1], sprite_id, PRE_HEAD_BASE + Vector2i(clock, 0), dir_to_atlas_transform(pre_dir))
		%SnakeAdditionnalVisuals.update(body[1], jumping_frame, PRE_HEAD_BASE + Vector2i(clock, 0), dir_to_atlas_transform(curr_dir))

	else: # Turning, so no jump management
		var base_pos = PRE_HEAD_BASE # Where do we begin the table in the sprites sheet
		var pre_head = base_pos + Vector2i(int(post_dir) * 4, int(pre_dir)) # start on top left of table then select right line and col using order up, down, left, right
		%SnakeLayer.set_cell(body[1], GROUND_ID, pre_head + Vector2i(clock, 0))
		%SnakeAdditionnalVisuals.update(body[1], jumping_frame, pre_head + Vector2i(clock, 0), 0)
	

func update_pre_tail_sp() -> void :
	var pre_tail = Direction.cells_to_dir(body[-3], body[-2])
	var post_tail = Direction.cells_to_dir(body[-2], body[-1]) # Reversed reading order for same indexing as pre_head
	if pre_tail == post_tail: # Going straight
		%SnakeLayer.set_cell(body[-2], GROUND_ID, PRE_TAIL_BASE + Vector2i(clock - 12, 0), dir_to_atlas_transform(pre_tail))
	else:
		var pre_head = PRE_TAIL_BASE + Vector2i(int(post_tail) * 4, int(pre_tail)) # start on top left of table then select right line and col using order up, down, left, right
		%SnakeLayer.set_cell(body[-2], GROUND_ID, pre_head + Vector2i(clock - 12, 0))


func update_tail_sp():
	var tail_dir = Direction.cells_to_dir(body[-2], body[-1])
	var tail = TAIL_BASE + Vector2i(clock, 0)
	%SnakeLayer.set_cell(body[-1], GROUND_ID, tail, dir_to_atlas_transform(tail_dir))

func update_head_sp():
	var head = HEAD_BASE + Vector2i(clock, 0)
	var layer 
	var sprite_id
	if jumping_frame:
		sprite_id = JUMP_ID
		layer = %snakeJumpingLayer
	else:
		sprite_id = GROUND_ID
		layer = %SnakeLayer
	layer.set_cell(body[0], sprite_id, head, dir_to_atlas_transform(curr_dir))
	%SnakeAdditionnalVisuals.update(body[0], jumping_frame, head, dir_to_atlas_transform(curr_dir))


func get_head_world_pos():
	return %SnakeLayer.map_to_local(body[0])

func activable_apple_spawn():
	if SnakeProps.consume_juice(1000):
		Apple.instantiate(self, body[0])

func smooth_actual_speed_step():
	if actual_speed != SnakeProps.target_speed:
		actual_speed = min(SnakeProps.target_speed, actual_speed + 0.02)


func _on_clock_tick() -> void:
	clock = (clock + 1) % 16
	if clock == 0:
		var last_jump_frame = jumping_frame
		jumping_frame = false
		step(last_jump_frame)
	if SnakeProps.game_state == SnakeProps.GAME_STATE.GAME_OVER:
		return
	smooth_actual_speed_step()
	if clock < 4:
		update_pre_head_sp()
	if SnakeProps.growth == 0 && clock >= 12:
		update_pre_tail_sp()
	if SnakeProps.growth == 0 || clock == 0:
		update_tail_sp()
	update_head_sp()


func _process(delta: float) -> void:
	var clock_rate = 16666 # vraiment hyper hyper important que ça soit un multiple de 16666 
	delta = delta * 1000 # get it in ms
	delta = delta * 1000 # get it in ns
	clock_collector += delta
	if SnakeProps.game_state == SnakeProps.GAME_STATE.RUNNING && clock_collector * actual_speed > clock_rate:
		for i in range(int(clock_collector * actual_speed / clock_rate)):
			_on_clock_tick()

		clock_collector = int(clock_collector) % (int(clock_rate / actual_speed))


func _ready() -> void:
	SnakeProps.SM = self
	pass # SnakeProps.update_max_juice()
