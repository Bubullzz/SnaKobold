extends CanvasLayer

class_name UpgradesManager

var curr_alpha_tween : Tween
var upgrading = false
var previous_speed
#Useful to prevent problems when end_upgrade sequence is called before tweens from start are done
func flush_tweens():
	if curr_alpha_tween:
		curr_alpha_tween.stop()

func choose_all_upgrades():
	var AllUpgradesList = %AllUpgradesList.get_children()
	AllUpgradesList.shuffle()
	%Upgrade1.set_upgrade(AllUpgradesList[0])
	%Upgrade2.set_upgrade(AllUpgradesList[1])
	%Upgrade3.set_upgrade(AllUpgradesList[2])
	
func start_upgrade_sequence():
	previous_speed = SnakeProps.SM.speed
	SnakeProps.JuicesList.pause()
	
	enable_buttons()
	choose_all_upgrades()
	upgrading = true
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 1, .4)	
	SnakeProps.SM.tween_speed(-1, 0, .1)

	curr_alpha_tween = alpha_tween
	
func end_upgrade_sequence():
	SnakeProps.JuicesList.play()

	flush_tweens()
	Engine.time_scale = max(Engine.time_scale,0.1)
	upgrading = false
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)#.set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 0, .1)	
	
	SnakeProps.SM.clock_collector = 0
	SnakeProps.SM.tween_speed(0.1, SnakeProps.SM.target_speed, .5)
	
func enable_buttons():
	for b in [%Upgrade1, %Upgrade2, %Upgrade3]:
		b.enable()
	%Upgrade2.focus_me()
	
	
func _ready():
	SnakeProps.UM = self
