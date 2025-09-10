extends CanvasLayer

class_name UpgradesManager

var curr_alpha_tween : Tween
var curr_time_scale_tween : Tween
var upgrading = false

#Useful to prevent problems when end_upgrade sequence is called before tweens from start are done
func flush_tweens():
	if curr_alpha_tween:
		curr_alpha_tween.stop()
	if curr_time_scale_tween:
		curr_time_scale_tween.stop()
		
func start_upgrade_sequence():
	enable_buttons()
	upgrading = true
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 1, .4)	
	var trans_time = 1
	var time_scale_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_OUT)
	time_scale_tween.tween_property(Engine, "time_scale", 0, .2)	
	
	curr_alpha_tween = alpha_tween
	curr_time_scale_tween = time_scale_tween
	
func end_upgrade_sequence():
	flush_tweens()
	Engine.time_scale = max(Engine.time_scale,0.1)
	upgrading = false
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)#.set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 0, .1)	
	
	var trans_time = .3
	var tween_1 = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)#.set_ease(Tween.EASE_OUT)
	tween_1.tween_property(Engine, "time_scale", 1, .2)	

func enable_buttons():
	for b in [%Upgrade1, %Upgrade2, %Upgrade3]:
		b.enable()
	%Upgrade2.focus_me()
	
	
func _ready():
	SnakeProps.UM = self
