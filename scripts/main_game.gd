extends Node

@export var width = 30
@export var height = 20
@export var noise_texture : NoiseTexture2D

enum DIR {UP, DOWN, LEFT, RIGHT}

var debug = false


func middle() -> Vector2i:
    return Vector2i(width / 2, height / 2)


func lakes(lake : Array[Vector2i], pos : Vector2i) -> void:
    # Reccursively find all the connected cells to initial pos
    if pos in lake || %EnvironmentManager.is_wall(pos):
        return
    lake.append(pos)
    lakes(lake, pos + Vector2i(1,0))
    lakes(lake, pos + Vector2i(-1,0))
    lakes(lake, pos + Vector2i(0,1))
    lakes(lake, pos + Vector2i(0,-1))


func proc_gen():
    var noise = noise_texture.noise
    noise.seed = randi()    
    var mid_width = width / 2
    var mid_height = height / 2

    # Generate random terrain from the Noise
    for i in range(1,width):
        for j in range(1, height):
            var val = noise.get_noise_2d(i, j)
            val += pow(Vector2i(i,j).distance_to(Vector2i(mid_width, mid_height)), 2.) * 0.001 
            if val > 0.5 :
                %EnvironmentManager.set_wall(Vector2i(i,j))
            %EnvironmentManager.set_floor(Vector2i(i,j))
    
    # Make sure there is space for the snake to spawn
    for i in range(mid_width - 15, mid_width + 15):
        for j in range(mid_height - 15, mid_height + 15):
            %EnvironmentManager.remove_wall(Vector2i(i,j))

    # Filling unreachable holes
    var accessible : Array[Vector2i] = [] 
    lakes(accessible, Vector2i(mid_width, mid_height))
    var un_accessible : Array[Vector2i] = []
    for i in range(1,width):
        for j in range(1, height):
            if Vector2i(i,j) not in accessible:
                un_accessible.append(Vector2i(i,j))
                %EnvironmentManager.set_wall(Vector2i(i,j))
    
    %EnvironmentManager.update_terrain_cells(un_accessible)

    return


func _input(_event):
    if Input.is_action_just_pressed("ui_up"):
        %SnakeManager.dir_buff_add(DIR.UP)
    if Input.is_action_just_pressed("ui_down"):
        %SnakeManager.dir_buff_add(DIR.DOWN)
    if Input.is_action_just_pressed("ui_right"):
       %SnakeManager. dir_buff_add(DIR.RIGHT)
    if Input.is_action_just_pressed("ui_left"):
        %SnakeManager.dir_buff_add(DIR.LEFT)
    if Input.is_key_pressed(KEY_A):
        %SnakeManager.activable_apple_spawn();

    # Debug
    if Input.is_key_pressed(KEY_C):
        %SnakeManager.clock_collector = 0.0
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.RUNNING

    if Input.is_key_pressed(KEY_D):
        debug = !debug
    if Input.is_key_pressed(KEY_R):
        get_tree().reload_current_scene()
    if Input.is_key_pressed(KEY_P):
        %SnakeManager.growth += 3
    if Input.is_key_pressed(KEY_J):
        %SnakeManager.update_juice(1000)
    if Input.is_key_pressed(KEY_H):
        %SnakeManager.health_points += 1
    if Input.is_key_pressed(KEY_S):
        %SnakeManager.actual_speed += 1
        %SnakeManager.target_speed += 1
    if Input.is_key_pressed(KEY_Q):
        %SnakeManager.actual_speed -= 1
        %SnakeManager.target_speed -= 1
    if Input.is_key_pressed(KEY_W):
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.DEBUG
        %SnakeManager._on_clock_tick()
        print("current clock : ",%SnakeManager.clock)
    if Input.is_key_pressed(KEY_X):
        %SnakeManager.game_state = %SnakeManager.GAME_STATE.DEBUG
        %SnakeManager._on_clock_tick()
        while %SnakeManager.clock > 0:
            %SnakeManager._on_clock_tick()
    if Input.is_key_pressed(KEY_Z):
        %MainCam.curr_state = %MainCam.STATE.DEBUG
        %MainCam.set_both_zoom(%MainCam.zoom.x * 0.7)

func update_game_labels():
    %GameLabels.text = ""
    var format = "%s : %s / %s"
    %GameLabels.text += format % ["juice" , %SnakeManager.juice , %SnakeManager.max_juice ]+ '\n'


func update_debug_labels():
    if !debug:
        %DebugLabels.text = ""
        return
    var format = "%s : %s"
    %DebugLabels.text = ""
    %DebugLabels.text += format % ["head_pos", %SnakeManager.body[0]] + '\n'
    %DebugLabels.text += format % ["actual_speed", %SnakeManager.actual_speed] + '\n'
    %DebugLabels.text += format % ["target_speed", %SnakeManager.target_speed] + '\n'
    %DebugLabels.text += format % ["clock", %SnakeManager.clock] + '\n'
    %DebugLabels.text += format % ["body length", len(%SnakeManager.body)] + '\n'
    %DebugLabels.text += format % ["health", %SnakeManager.health_points] + '\n'


func update_debug_boxes():
    for cell in %DebugLayer.get_used_cells():
        %DebugLayer.set_cell(cell, -1, Vector2i(0,0))
    if debug:
        for part in %SnakeManager.body:
           %DebugLayer.set_cell(part, 0, Vector2i(0,0))
        %DebugLayer.set_cell(%SnakeManager.body[0] + %MainCam.lookahead * Direction.dir_to_vec(%SnakeManager.curr_dir), 0, Vector2i(0,0)) # XXX change lookahaed color
        

func _process(_delta: float) -> void:
    update_debug_labels()
    update_debug_boxes()
    update_game_labels()
    return


func _ready():
    proc_gen()
    %SnakeManager.place_snake(middle())
    %SnakeManager.place_apple()
    %SnakeManager.place_apple()
    %SnakeManager.place_juice()

    %JuiceBar.max_value = %SnakeManager.max_juice

    %MainCam.position_smoothing_enabled = false
    %MainCam.position = %SnakeLayer.map_to_local(%SnakeManager.body[0])
    %MainCam.set_both_zoom(0.6)
    await get_tree().create_timer(0.1).timeout 
    %MainCam.position_smoothing_enabled = true
    %MainCam.position_smoothing_speed = 1.
