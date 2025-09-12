extends Node

signal juice_combo_updated

enum GAME_STATE {RUNNING, PAUSED, GAME_OVER, DEBUG}

var game_state : GAME_STATE = GAME_STATE.RUNNING
var health_points = 3
var max_juice = 0
var juice_update_thresh = 1000
var max_juice_step = 1000
var juice = 0
var juice_combo = 1
var max_juice_combo = 10
var min_juice_combo = 1
var nb_juices_missed = 0
var max_allowed_misses = 0
var jump_price = 500
var target_speed = 2
var growth : int = 0
var SM : Node # The SnakeManager
var JuiceBar : Node
var UM : UpgradesManager

func growing() -> bool:
	if growth > 0:
		growth -= 1
		update_max_juice()
		return true
	return false


func update_juice_combo(value: int) -> void:
	juice_combo = min(value, max_juice_combo)
	juice_combo_updated.emit(juice_combo)
	
	
func on_juice_consumed():
	nb_juices_missed = 0
	update_juice(100 * juice_combo)
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
