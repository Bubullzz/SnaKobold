extends Node

class_name Stats

var nb_apples_eaten = 0
var total_juice_gathered = 0
var nb_juice_spilled = 0
var max_combo = 1
var number_of_collisions = 0

func _ready():
	Signals.apple_eaten.connect(func(_x): nb_apples_eaten += 1)
	Signals.juice_eaten.connect(func(x): total_juice_gathered += x)
	Signals.juice_spilled.connect(func(_x): nb_juice_spilled += 1)
	Signals.juice_combo_updated.connect(func(_old, new): max_combo = max(max_combo, new))
	Signals.on_collision.connect(func(): number_of_collisions += 1)

func _process(_delta: float) -> void:
	return
