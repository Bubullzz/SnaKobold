extends Node

enum DIR {UP, DOWN, LEFT, RIGHT}
enum EAT {APPLE, JUICE}


var width
var height
@export var noise_texture : NoiseTexture2D

var debug = false
var mooving = false

func middle() -> Vector2i:
	return Vector2i(width / 2, height / 2)

func restart():
	SnakeProps.init_vars()
	get_tree().change_scene_to_file("res://main_game.tscn")

func stop_game():
	print("recieved game_lost signal, stopping game")
	SnakeProps.JuicesList.pause()
	SnakeProps.SM.speed = 0
	SnakeProps.SM.target_speed = 0
	if SnakeProps.SM.speed_tweener:
		SnakeProps.SM.speed_tweener.kill()
	%TailParticles.stop()
	%EndGameCanvas.get_child(0).visible = true
	%EndGameCanvas.get_child(0).appear()
	%LifeManager.stop()


func _input(_event):
	if _event is InputEventKey and _event.pressed:
		mooving = true
		SnakeProps.SM.tween_speed(-1,-1, .5)
	if ! SnakeProps.UM.upgrading: #Only register Inputs when not in upgrading menu
		if Input.is_action_just_pressed("ui_up"):
			%SnakeManager.dir_buff_add(DIR.UP)
		if Input.is_action_just_pressed("ui_down"):
			%SnakeManager.dir_buff_add(DIR.DOWN)
		if Input.is_action_just_pressed("ui_right"):
			%SnakeManager.dir_buff_add(DIR.RIGHT)
		if Input.is_action_just_pressed("ui_left"):
			%SnakeManager.dir_buff_add(DIR.LEFT)
		if  Input.is_action_just_pressed("Action"):
			%SnakeManager.activable_apple_spawn();

	# Debug
	if !SnakeProps.is_cheating:
		return
	if Input.is_key_pressed(KEY_C):
		%SnakeManager.clock_collector = 0.0
		SnakeProps.game_state = SnakeProps.GAME_STATE.RUNNING

	if Input.is_key_pressed(KEY_G):
		debug = !debug
	if Input.is_key_pressed(KEY_N):
		Juice.instantiate(self, middle())
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene_to_file("res://main_game.tscn")
	if Input.is_key_pressed(KEY_9):
		SnakeProps.growth += 3
	if Input.is_key_pressed(KEY_V):
		SnakeProps.update_juice(5000)
	if Input.is_key_pressed(KEY_Z):
		SnakeProps.update_juice(1000)
	if Input.is_key_pressed(KEY_B):
		%SnakeManager.actual_speed -= 1
		SnakeProps.target_speed -= 1
	if Input.is_key_pressed(KEY_2):
		SnakeProps.SM.target_speed -= 1
		SnakeProps.SM.speed = SnakeProps.SM.target_speed
	if Input.is_key_pressed(KEY_3):
		SnakeProps.SM.target_speed += 1
		SnakeProps.SM.speed = SnakeProps.SM.target_speed
	if Input.is_key_pressed(KEY_4):
		SnakeProps.MapGenerator.level_up_map()
	if Input.is_key_pressed(KEY_5):
		SnakeProps.UM.start_upgrade_sequence()
	if Input.is_key_pressed(KEY_0):
		restart()
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
		pass
		#%MainCam.curr_state = %MainCam.STATE.DEBUG
		#%MainCam.set_both_zoom(%MainCam.zoom.x * 0.7)

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


func update_debug_boxes():
	for cell in %DebugLayer.get_used_cells():
		%DebugLayer.set_cell(cell, -1, Vector2i(0,0))
	if debug:
		for part in %SnakeManager.body:
			%DebugLayer.set_cell(part, 0, Vector2i(0,0))
		#%DebugLayer.set_cell(%SnakeManager.body[0] + %MainCam.lookahead * Direction.dir_to_vec(%SnakeManager.curr_dir), 0, Vector2i(0,0)) # XXX change lookahaed color
		

func _process(_delta: float) -> void:
	update_debug_labels()
	update_debug_boxes()
	update_game_labels()
	return


func _ready():
	Signals.restart.connect(restart)
	Signals.game_lost.connect(stop_game)
	
	SnakeProps.MainGame = self
	
	var start: Vector2i = Vector2i(4,8)
	width = $MapGenerator.width
	height = $MapGenerator.height
	#array_to_map($MapGenerator.map)
	%SnakeManager.place_snake(start)
	%JuiceBar.max_value = SnakeProps.max_juice

	%MainCam.position_smoothing_enabled = false
	#%MainCam.position = %SnakeLayer.map_to_local(%SnakeManager.body[0])
	#%MainCam.set_both_zoom(0.6)
	await get_tree().create_timer(0.1).timeout 
	%MainCam.position_smoothing_enabled = true
	%MainCam.position_smoothing_speed = 1.
	SnakeProps.update_max_juice()

	Apple.instantiate(start)

	for i in range(16):
		SnakeProps.SM._on_clock_tick()

	%OpeningRect.set_instance_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)
