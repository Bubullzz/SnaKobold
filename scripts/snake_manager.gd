extends Node

enum GAME_STATE {RUNNING, PAUSED, GAME_OVER, DEBUG}
enum BODY_PART {HEAD, PRE_HEAD, BODY, PRE_TAIL, TAIL}
var GROUND_ID = 1
var JUMP_ID = 1 
var VERT_BODY = Vector2i(3,4)
var HOR_BODY = Vector2i(11,6)
var health_points = 3


func is_snake(pos):
	return %SnakeLayer.get_cell_source_id(pos) == GROUND_ID || %snakeJumpingLayer.get_cell_source_id(pos) == JUMP_ID

# XXX vraiment cracra mais bon

func check_accessible(pos):
	var sum = 0
	for dir in [Direction.DIR.UP, Direction.DIR.DOWN, Direction.DIR.LEFT, Direction.DIR.RIGHT]:
		if %EnvironmentLayer.is_wall(pos + Direction.dir_to_vec(dir)):
			sum += 1
	return sum < 3

	
func place_apple():
	var apple_pos = Vector2i(body[0].x + (randi() % 30) - 15, %SnakeManager.body[0].y + (randi() % 20) - 10)
	while is_snake(apple_pos) || %EnvironmentLayer.is_wall(apple_pos) || !check_accessible(apple_pos):
		apple_pos = Vector2i(body[0].x + (randi() % 30) - 15, %SnakeManager.body[0].y + (randi() % 20) - 10)

	%appleLayer.set_cell(apple_pos, 1, Vector2i(0, 0))


func place_snake(pos):
	for i in range(4):
		body.push_back(pos + Direction.dir_to_vec(Direction.DIR.LEFT) * i)
		%SnakeLayer.set_cell(body[-1], GROUND_ID, Vector2i(0, 0))

var dir_buffer = [null, null] 
var input_jump = 0
var game_state : GAME_STATE = GAME_STATE.RUNNING
var jumping_frame = false


# All snake pos in the TileMap
var body : Array[Vector2i]
var curr_dir : Direction.DIR = Direction.DIR.RIGHT
var growth : int = 0
var clock : int = 0 # The clock used for updating the snake. One pixel per tick
var clock_collector : float = 0.0
var target_speed = 2
var actual_speed = target_speed

func dir_buff_add(dir):
	if dir_buffer[0] == null:
		dir_buffer[0] = dir
	else: dir_buffer[1] = dir

func dir_buff_consume():
	var tmp = dir_buffer[0]
	dir_buffer[0] = dir_buffer[1]
	dir_buffer[1] = null
	return tmp


func apple_check():
	if %appleLayer.get_cell_source_id(body[0]) == 1:
		growth += 1
		%appleLayer.set_cell(body[0])
		place_apple()

func pop_tail():
	var old_tail_co = body.pop_back()
	if %snakeJumpingLayer.get_cell_source_id(old_tail_co) == (JUMP_ID):
		%snakeJumpingLayer.set_cell(old_tail_co)
		if ! %EnvironmentLayer.is_wall(old_tail_co): # If not in wall then the tail is passing under body and needs update
			var sprite = VERT_BODY if Direction.hor(Direction.cells_to_dir(old_tail_co, body[-1])) else HOR_BODY 
			%SnakeLayer.set_cell(old_tail_co, GROUND_ID, sprite)
	else:
		%SnakeLayer.set_cell(old_tail_co)


func handle_collision():
	health_points -= 1
	%SnakeLayer.set_cell(body.pop_front())
	%SnakeLayer.set_cell(body.pop_front())
	actual_speed = 0.1
	curr_dir = Direction.cells_to_dir(body[1], body[0])
	var ideal_cam_pos = body[0] + 1 * Direction.dir_to_vec(Direction.opp(curr_dir))
	%MainCam.set_tmp_scene(%SnakeLayer.map_to_local(ideal_cam_pos), 6, 1, 4.)
	%MainCam.start_shake()

	dir_buffer = [null, null]

func step():
	# First update the tail
	if growth == 0:
		pop_tail()
	else:
		growth -= 1

	# Update Direction from inputs in the last 16-frame
	var d = dir_buff_consume()
	if Direction.opp(d) == curr_dir || d == curr_dir:
		d = dir_buff_consume()
	if d != null && Direction.opp(d) != curr_dir:
		curr_dir = d
	
	# Update body data
	var expected_head_pos = body[0] + Direction.dir_to_vec(curr_dir)
	if is_snake(expected_head_pos) || %EnvironmentLayer.is_wall(expected_head_pos):
		if input_jump: 
			jumping_frame = true
			body.push_front(expected_head_pos) 
			input_jump = 0
		else:
			handle_collision()
	else:
		body.push_front(expected_head_pos)

	apple_check()
	


func update_pre_head_sp() -> void :
	var pre_dir = Direction.cells_to_dir(body[2], body[1])
	var post_dir = Direction.cells_to_dir(body[1], body[0])
	var layer
	var base_pos = Vector2i(0,4) # Where do we begin the table in the sprites sheet
	var sprite_id
	if %snakeJumpingLayer.get_cell_source_id(body[1]) == JUMP_ID:
		layer = %snakeJumpingLayer
		sprite_id = JUMP_ID
	else:
		layer = %SnakeLayer
		sprite_id = GROUND_ID
	var pre_head = base_pos + Vector2i(int(post_dir) * 4, int(pre_dir)) # start on top left of table then select right line and col using order up, down, left, right
	layer.set_cell(body[1], sprite_id, pre_head + Vector2i(clock, 0))

func update_pre_tail_sp() -> void :
	var base_pos = Vector2i(0,12) # Where do we begin the table in the sprites sheet
	var pre_tail = Direction.cells_to_dir(body[-3], body[-2])
	var post_tail = Direction.cells_to_dir(body[-2], body[-1]) # Reversed reading order for same indexing as pre_head
	var pre_head = base_pos + Vector2i(int(post_tail) * 4, int(pre_tail)) # start on top left of table then select right line and col using order up, down, left, right
	%SnakeLayer.set_cell(body[-2], GROUND_ID, pre_head + Vector2i(clock - 12, 0))


func update_tail_sp():
	var tail_dir = Direction.cells_to_dir(body[-2], body[-1])
	var tail = Vector2i(clock, 8 + int(tail_dir))
	%SnakeLayer.set_cell(body[-1], GROUND_ID, tail)

func update_head_sp():
	var head = Vector2i(clock, int(curr_dir))
	var layer 
	var sprite_id
	if jumping_frame:
		sprite_id = JUMP_ID
		layer = %snakeJumpingLayer
	else:
		sprite_id = GROUND_ID
		layer = %SnakeLayer
	layer.set_cell(body[0], sprite_id, head)


func smooth_actual_speed_step():
	if actual_speed != target_speed:
		actual_speed = min(target_speed, actual_speed + 0.02)


func _on_clock_tick() -> void:
	clock = (clock + 1) % 16
	if clock == 0:
		jumping_frame = false
		step()
		input_jump = max(0, input_jump - 1)
	if game_state == GAME_STATE.GAME_OVER:
		return
	smooth_actual_speed_step()
	if clock < 4:
		update_pre_head_sp()
	if growth == 0 && clock >= 12:
		update_pre_tail_sp()
	if growth == 0 || clock == 0:
		update_tail_sp()
	update_head_sp()


func _process(delta: float) -> void:
	var clock_rate = 16666 # vraiment hyper hyper important que ça soit un multiple de 16666 
	delta = delta * 1000 # get it in ms
	delta = delta * 1000 # get it in ns
	clock_collector += delta
	if game_state == GAME_STATE.RUNNING && clock_collector * actual_speed > clock_rate:
		for i in range(int(clock_collector * actual_speed / clock_rate)):
			_on_clock_tick()

		clock_collector = int(clock_collector) % (int(clock_rate / actual_speed))
	
