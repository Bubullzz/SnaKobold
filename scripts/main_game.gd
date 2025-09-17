extends Node

enum DIR {UP, DOWN, LEFT, RIGHT}
enum EAT {APPLE, JUICE}


var width
var height
@export var noise_texture : NoiseTexture2D

var debug = false

func middle() -> Vector2i:
	return Vector2i(width / 2, height / 2)

func array_to_map(arr): # Array2d of height * width
	var walls: Array[Vector2i]
	for i in range(height):
		for j in range(width):
			%EnvironmentManager.set_floor(Vector2i(i,j))
			if !arr[i][j]:
				%EnvironmentManager.set_wall(Vector2i(i,j))
				walls.append(Vector2i(i,j))
	%EnvironmentManager.update_terrain_cells(walls)


func _input(_event):
	if ! SnakeProps.UM.upgrading: #Only register Inputs when not in upgrading menu
		if Input.is_action_just_pressed("ui_up"):
			%SnakeManager.dir_buff_add(DIR.UP)
		if Input.is_action_just_pressed("ui_down"):
			%SnakeManager.dir_buff_add(DIR.DOWN)
		if Input.is_action_just_pressed("ui_right"):
			%SnakeManager. dir_buff_add(DIR.RIGHT)
		if Input.is_action_just_pressed("ui_left"):
			%SnakeManager.dir_buff_add(DIR.LEFT)
		if  Input.is_action_just_pressed("Action"):
			%SnakeManager.activable_apple_spawn();

	# Debug
	if Input.is_key_pressed(KEY_C):
		%SnakeManager.clock_collector = 0.0
		SnakeProps.game_state = SnakeProps.GAME_STATE.RUNNING

	if Input.is_key_pressed(KEY_G):
		debug = !debug
	if Input.is_key_pressed(KEY_N):
		Juice.instantiate(self, middle())
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene_to_file("res://main_game.tscn")
	if Input.is_key_pressed(KEY_P):
		SnakeProps.growth += 3
	if Input.is_key_pressed(KEY_V):
		SnakeProps.update_juice(5000)
	if Input.is_key_pressed(KEY_Z):
		SnakeProps.update_juice(1000)
	if Input.is_key_pressed(KEY_H):
		SnakeProps.health_points += 1	
	if Input.is_key_pressed(KEY_N):
		%SnakeManager.actual_speed += 1
		SnakeProps.target_speed += 1
	if Input.is_key_pressed(KEY_B):
		%SnakeManager.actual_speed -= 1
		SnakeProps.target_speed -= 1
	if Input.is_key_pressed(KEY_1):
		for i in range(50):
			Apple.instantiate(%SnakeManager.body[0])
	if Input.is_key_pressed(KEY_V):
		SnakeProps.game_state = SnakeProps.GAME_STATE.DEBUG
		%SnakeManager._on_clock_tick()
		print("current clock : ",%SnakeManager.clock)
	if Input.is_key_pressed(KEY_X):
		SnakeProps.game_state = SnakeProps.GAME_STATE.DEBUG
		%SnakeManager._on_clock_tick()
		while %SnakeManager.clock > 0:
			%SnakeManager._on_clock_tick()
	if Input.is_key_pressed(KEY_Z):
		%MainCam.curr_state = %MainCam.STATE.DEBUG
		%MainCam.set_both_zoom(%MainCam.zoom.x * 0.7)

func update_game_labels():
	%GameLabels.text = ""
	var format = "%s: %s / %s"
	%GameLabels.text += format % ["juice" , SnakeProps.juice , SnakeProps.max_juice ]


func update_debug_labels():
	if !debug:
		%DebugLabels.text = ""
		return
	var format = "%s : %s"
	%DebugLabels.text = ""
	%DebugLabels.text += format % ["head_pos", %SnakeManager.body[0]] + '\n'
	%DebugLabels.text += format % ["actual_speed", %SnakeManager.actual_speed] + '\n'
	%DebugLabels.text += format % ["target_speed", SnakeProps.target_speed] + '\n'
	%DebugLabels.text += format % ["clock", %SnakeManager.clock] + '\n'
	%DebugLabels.text += format % ["body length", len(%SnakeManager.body)] + '\n'
	%DebugLabels.text += format % ["health", SnakeProps.health_points] + '\n'


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
	width = $MapGenerator.width
	height = $MapGenerator.height
	array_to_map($MapGenerator.map)
	%SnakeManager.place_snake(middle())
	%JuiceBar.max_value = SnakeProps.max_juice

	%MainCam.position_smoothing_enabled = false
	%MainCam.position = %SnakeLayer.map_to_local(%SnakeManager.body[0])
	%MainCam.set_both_zoom(0.6)
	await get_tree().create_timer(0.1).timeout 
	%MainCam.position_smoothing_enabled = true
	%MainCam.position_smoothing_speed = 1.
	SnakeProps.update_max_juice()

	Apple.instantiate(middle())
	Apple.instantiate(middle())
	Juice.instantiate(self, middle())

	%OpeningRect.set_instance_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)
