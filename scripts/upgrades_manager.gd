extends CanvasLayer

class_name UpgradesManager

func start_upgrade_sequence():
	visible = true
	var trans_time = 1
	var tween_1 = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_OUT)
	tween_1.tween_property(Engine, "time_scale", 0.05, .2)	
	
func end_upgrade_sequence():
	visible = false
	var trans_time = .3
	var tween_1 = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_OUT)
	tween_1.tween_property(Engine, "time_scale", 1, .2)	


func _ready():
	SnakeProps.UM = self
