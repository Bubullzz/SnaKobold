extends Node

@export var width = 30
@export var height = 20
@export var noise_texture : NoiseTexture2D

enum DIR {UP, DOWN, LEFT, RIGHT}

var debug = true


func lakes(lake, pos):
    if pos in lake || $GameTiles/background.get_cell_source_id(pos) == 2:
        return
    lake.append(pos)
    lakes(lake, pos + Vector2(1,0))
    lakes(lake, pos + Vector2(-1,0))
    lakes(lake, pos + Vector2(0,1))
    lakes(lake, pos + Vector2(0,-1))


func proc_gen():
    var noise = noise_texture.noise
    noise.seed = randi()    
    var mid_width = width / 2
    var mid_height = height / 2

    for i in range(1,width):
        for j in range(1, height):
            var val = noise.get_noise_2d(i, j)
            val += pow(Vector2(i,j).distance_to(Vector2(mid_width, mid_height)), 2.) * 0.001 
            if val > 0.5 :
                $GameTiles/background.set_cell(Vector2(i,j),2,Vector2(0,0))
            else:
                $GameTiles/background.set_cell(Vector2(i,j),3,Vector2(0,0))
    
    for i in range(mid_width - 5, mid_width + 5):
        for j in range(mid_height - 5, mid_height + 5):
            $GameTiles/background.set_cell(Vector2(i,j),3,Vector2(0,0))
    var lake = [] # fill holes
    lakes(lake, Vector2(mid_width, mid_height))
    for i in range(1,width):
        for j in range(1, height):
            if Vector2(i,j) not in lake:
                $GameTiles/background.set_cell(Vector2(i,j),2,Vector2(0,0))

func _input(_event):
    if Input.is_action_just_pressed("ui_up"):
        %SnakeManager.dir_buff_add(DIR.UP)
    if Input.is_action_just_pressed("ui_down"):
        %SnakeManager.dir_buff_add(DIR.DOWN)
    if Input.is_action_just_pressed("ui_right"):
       %SnakeManager. dir_buff_add(DIR.RIGHT)
    if Input.is_action_just_pressed("ui_left"):
        %SnakeManager.dir_buff_add(DIR.LEFT)
    if Input.is_key_pressed(KEY_SPACE):
        %SnakeManager.input_jump = 4



    # Debug
    if Input.is_key_pressed(KEY_C):
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.RUNNING
    if Input.is_key_pressed(KEY_D):
        debug = !debug
    if Input.is_key_pressed(KEY_R):
        get_tree().reload_current_scene()
    if Input.is_key_pressed(KEY_P):
        %SnakeManager.growth += 3
    if Input.is_key_pressed(KEY_S):
        %SnakeManager.speed += 1
    if Input.is_key_pressed(KEY_Q):
        %SnakeManager.speed -= 1
    if Input.is_key_pressed(KEY_W):
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.DEBUG
        %SnakeManager._on_clock_tick()
        print("current clock : ",%SnakeManager.clock)
    if Input.is_key_pressed(KEY_X):
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.DEBUG
        %SnakeManager._on_clock_tick()
        while %SnakeManager.clock > 0:
            %SnakeManager._on_clock_tick()

func update_debug_labels():
    if !debug:
        %DebugLabels.text = ""
        return
    var format = "%s : %s"
    %DebugLabels.text = ""
    %DebugLabels.text += format % ["head_pos", %SnakeManager.body[0]] + '\n'
    %DebugLabels.text += format % ["speed", %SnakeManager.speed] + '\n'
    %DebugLabels.text += format % ["clock", %SnakeManager.clock] + '\n'
    %DebugLabels.text += format % ["body length", len(%SnakeManager.body)] + '\n'

func update_debug_boxes():
    for cell in %DebugLayer.get_used_cells():
        %DebugLayer.set_cell(cell, -1, Vector2(0,0))
    if debug:
        for part in %SnakeManager.body:
           %DebugLayer.set_cell(part, 0, Vector2(0,0))

func _process(delta: float) -> void:
    update_debug_labels()
    update_debug_boxes()
    var snake_head_pos = $GameTiles/snakeLayer.map_to_local(%SnakeManager.body[0])
    var anchor = $GameTiles/snakeLayer.map_to_local(%SnakeManager.body[0] +  Direction.dir_to_vec(%SnakeManager.curr_dir)) # One tile after head
    var dir_scaled = anchor - snake_head_pos # Vector of norm 1 in the right direction (conversion from tiles to local coordinates)

    var ideal_pos = snake_head_pos + 6 * Direction.dir_to_vec(%SnakeManager.curr_dir) + (dir_scaled * %SnakeManager.clock) / 16
    var movement = ideal_pos - $jsp.position
    $jsp.position += movement * delta * 4
    return


func set_walls():
    for i in range(width):
        $GameTiles/background.set_cell(Vector2(i,0),2,Vector2(0,0))
        $GameTiles/background.set_cell(Vector2(i,height),2,Vector2(0,0))
    for i in range(height):
        $GameTiles/background.set_cell(Vector2(0,i),2,Vector2(0,0))
        $GameTiles/background.set_cell(Vector2(width,i),2,Vector2(0,0))
    $GameTiles/background.set_cell(Vector2(width,height),2,Vector2(0,0))

func set_bg():
    for i in range(1,width):
        for j in range(1, height):
            $GameTiles/background.set_cell(Vector2(i,j),3,Vector2(0,0))


func _ready():
    #set_walls()
    #set_bg()
    proc_gen()
    print(Vector2(width/2, height/2))
    %SnakeManager.place_snake(Vector2(width/2, height/2))
    %SnakeManager.place_apple()
