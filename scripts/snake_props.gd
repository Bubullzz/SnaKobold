extends Node


enum GAME_STATE {RUNNING, PAUSED, GAME_OVER, DEBUG}

# === Base Values ===
const BASE_JUICE_UPDATE_THRESH = 1000
const BASE_MAX_JUICE_STEP = 500
const BASE_JUICE_COMBO = 1
const BASE_MAX_JUICE_COMBO = 10
const BASE_MIN_JUICE_COMBO = 1
const BASE_NB_JUICES_MISSED = 0
const BASE_MAX_ALLOWED_MISSES = 0
const BASE_JUMP_PRICE = 500
const BASE_GROWTH = 0
const BASE_JUICE = 0
const BASE_GAME_STATE = GAME_STATE.RUNNING
const BASE_JUICE_WAIT_TIME = 3

# === Runtime Values ===
var game_state : GAME_STATE
var max_juice : int
var juice_update_thresh : int
var max_juice_step : int
var juice : int
var juice_combo : int
var max_juice_combo : int
var min_juice_combo : int
var nb_juices_missed : int
var max_allowed_misses : int
var base_jump_price : int
var growth : int
var jump_price: int = 99999999 # Gets initialized right on 3rd upgrade
var juice_wait_time = 3

var SM : Node # The SnakeManager
var ApplesList : Node
var EnvironmentManager : Node
var JuicesList : Node
var JuiceBar : Node
var GameTiles : Node
var UM : UpgradesManager
var OwnedUpgradesList : Node
var MapGenerator : Node
var MainGame : Node
var eatables_pos = {} # Dictionary of all the apples positions in the form Vector2i : instance

func init_vars() -> void:
	game_state = BASE_GAME_STATE
	max_juice = 0
	juice_update_thresh = BASE_JUICE_UPDATE_THRESH
	max_juice_step = BASE_MAX_JUICE_STEP
	juice = BASE_JUICE
	juice_combo = BASE_JUICE_COMBO
	max_juice_combo = BASE_MAX_JUICE_COMBO
	min_juice_combo = BASE_MIN_JUICE_COMBO
	nb_juices_missed = BASE_NB_JUICES_MISSED
	max_allowed_misses = BASE_MAX_ALLOWED_MISSES
	jump_price = 99999999 # Will be reset during the 3rd upgrade
	base_jump_price = BASE_JUMP_PRICE
	growth = BASE_GROWTH
	eatables_pos.clear()
	juice_wait_time = BASE_JUICE_WAIT_TIME

func _ready():
	init_vars()
	
func growing() -> bool:
	if growth > 0:
		growth -= 1
		update_max_juice()
		SnakeProps.MapGenerator.try_update_map()

		return true
	return false

func pause_time():
	JuicesList.pause()


func play_time():
	JuicesList.play()
	
func update_juice_combo(value: int) -> void:
	var old = juice_combo
	juice_combo = min(value, max_juice_combo)
	Signals.juice_combo_updated.emit(old, juice_combo)
	
	
func on_juice_consumed():
	nb_juices_missed = 0
	update_juice(100 * juice_combo)
	Signals.juice_eaten.emit(100 * juice_combo)
	update_juice_combo(juice_combo + 1)

	
func on_juice_spilled() -> bool:
	nb_juices_missed += 1
	if nb_juices_missed > max_allowed_misses:
		update_juice_combo(min_juice_combo)
		return true
	return false
	
	
func update_juice(value : int):
	juice += value
	juice = min(juice, max_juice)
	juice = max(juice, 0)
	JuiceBar.update_bar_value()


func consume_juice(value : int) -> bool:
	if juice >= value:
		update_juice(-value)
		return true
	return false


func get_next_juice_update_thresh() -> int:
	if juice_update_thresh >= 5 * max_juice_step:
		max_juice_step *= 5
	return juice_update_thresh + max_juice_step


func update_max_juice() -> void:
	if len(SM.body) * 100 >= juice_update_thresh:
		juice_update_thresh = get_next_juice_update_thresh()
		UM.start_upgrade_sequence()
	max_juice = len(SM.body) * 100
	
	JuiceBar.update_bar_shape()
