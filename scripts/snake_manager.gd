extends Node

enum GAME_STATE {RUNNING, PAUSED, GAME_OVER, DEBUG}
enum BODY_PART {HEAD, PRE_HEAD, BODY, PRE_TAIL, TAIL}
var GROUND_ID = 1
var JUMP_ID = 1

# XXX vraiment cracra mais bon
func place_apple():
    var apple_pos = Vector2()
    var snake_body = %SnakeManager.body
    apple_pos.x = 1 + randi() % 29
    apple_pos.y = 1 + randi() % 19
    while apple_pos in snake_body:
        apple_pos.x = 1 + randi() % 29
        apple_pos.y = 1 + randi() % 19 

    %appleLayer.set_cell(apple_pos, 1, Vector2(0, 0))

var dir_buffer = [null, null] 
var input_jump = false
var game_state : GAME_STATE = GAME_STATE.RUNNING
var jumping_frame = false

# All snake pos in the TileMap
var body : Array[Vector2]
var curr_dir : Direction.DIR
var growth : int = 0
var clock : int = 0 # The clock used for updating the snake. One pixel per tick
var clock_collector : float = 0.0
var speed = 2

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
        growth += 4
        %appleLayer.set_cell(body[0])
        place_apple()


func update_pos():
    # First update the tail
    if growth == 0:
        var old_tail_co = body.pop_back()
        %snakeLayer.set_cell(old_tail_co)
    else:
        growth -= 1

    # Update Direction from inputs in the last 16-frame
    var d = dir_buff_consume()
    if Direction.opp(d) == curr_dir || d == curr_dir:
        d = dir_buff_consume()
    if d != null && Direction.opp(d) != curr_dir:
        curr_dir = d
    
    # Update body data
    var neaw_head_pos = body[0] + Direction.dir_to_vec(curr_dir)
    if neaw_head_pos in body || %background.get_cell_source_id(neaw_head_pos) == 2: # 2 is the wall
        print("in wall or body")
        if input_jump: 
            print("jumping")
            jumping_frame = true
            body.push_front(neaw_head_pos)
        else:
            game_state = GAME_STATE.GAME_OVER
    else:
        body.push_front(neaw_head_pos)

    apple_check()
    


func update_pre_head_sp() -> void :
    var pre_dir = Direction.cells_to_dir(body[2], body[1])
    var post_dir = Direction.cells_to_dir(body[1], body[0])
    var layer
    var base_pos = Vector2(0,4) # Where do we begin the table in the sprites sheet
    var sprite_id
    if %snakeJumpingLayer.get_cell_source_id(body[1]) == JUMP_ID:
        layer = %snakeJumpingLayer
        sprite_id = JUMP_ID
    else:
        layer = %snakeLayer
        sprite_id = GROUND_ID
    var pre_head = base_pos + Vector2(int(post_dir) * 4, int(pre_dir)) # start on top left of table then select right line and col using order up, down, left, right
    layer.set_cell(body[1], sprite_id, pre_head + Vector2(clock, 0))

func update_pre_tail_sp() -> void :
    var base_pos = Vector2(0,12) # Where do we begin the table in the sprites sheet
    var pre_tail = Direction.cells_to_dir(body[-3], body[-2])
    var post_tail = Direction.cells_to_dir(body[-2], body[-1]) # Reversed reading order for same indexing as pre_head
    var pre_head = base_pos + Vector2(int(post_tail) * 4, int(pre_tail)) # start on top left of table then select right line and col using order up, down, left, right
    %snakeLayer.set_cell(body[-2], GROUND_ID, pre_head + Vector2(clock - 12, 0))


func update_tail_sp():
    var tail_dir = Direction.cells_to_dir(body[-2], body[-1])
    var tail = Vector2(clock, 8 + int(tail_dir))
    %snakeLayer.set_cell(body[-1], GROUND_ID, tail)

func update_head_sp():
    var head = Vector2(clock, int(curr_dir))
    var layer 
    var sprite_id
    if jumping_frame:
        sprite_id = JUMP_ID
        layer = %snakeJumpingLayer
    else:
        sprite_id = GROUND_ID
        layer = %snakeLayer
    layer.set_cell(body[0], sprite_id, head)


func _on_clock_tick() -> void:
    clock = (clock + 1) % 16
    if clock == 0:
        jumping_frame = false
        update_pos()
        input_jump = false
    if game_state == GAME_STATE.GAME_OVER:
        return
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
    if game_state == GAME_STATE.RUNNING && clock_collector > clock_rate:
        for i in range(speed):
            _on_clock_tick()
        clock_collector = int(clock_collector) % int(clock_rate)
    

func _init() -> void:
    body = [Vector2(5,3), Vector2(4,3), Vector2(3,3), Vector2(2,3)]
