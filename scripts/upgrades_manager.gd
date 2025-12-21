extends CanvasLayer

class_name UpgradesManager

var curr_alpha_tween : Tween
var level = 0
var upgrading = false
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

func beginning_upgrade():
	%Upgrade2.set_upgrade(%AllUpgradesList.get_child(0)) # Need to put the right one in 0 position
	%Upgrade2.disable_grey_frame()
	%Upgrade1.set_upgrade(%OwnedUpgradesList.get_child(0))
	%Upgrade3.set_upgrade(%OwnedUpgradesList.get_child(0)) # Need to put the right one in 0 position
	%Upgrade1.disable()
	%Upgrade3.disable()
	
	
func start_upgrade_sequence():
	SnakeProps.Audio.open_upgrade_sound()
	level += 1
	SnakeProps.JuicesList.pause()
	enable_buttons()
	
	if level == 4:
		%Upgrade1.disable_grey_frame()
		%Upgrade3.disable_grey_frame()
	if level <= 3:
		beginning_upgrade()
	else:
		choose_all_upgrades()
	upgrading = true
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 1, .4)	
	SnakeProps.SM.tween_speed(-1, 0, .1)

	curr_alpha_tween = alpha_tween
	
func end_upgrade_sequence():
	SnakeProps.Audio.close_upgrade_sound()
	disable_buttons()
	flush_tweens()
	upgrading = false
	var alpha_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)#.set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property($Controller, "modulate:a", 0, .1)	
	
	SnakeProps.SM.clock_collector = 0
	SnakeProps.SM.tween_speed(0.1, SnakeProps.SM.target_speed, .5)
	await get_tree().create_timer(.01).timeout
	SnakeProps.JuicesList.play()
	
	
func enable_buttons():
	for b in [%Upgrade1, %Upgrade2, %Upgrade3]:
		b.enable()
	%Upgrade2.focus_me()

func disable_buttons():
	for b in [%Upgrade1, %Upgrade2, %Upgrade3]:
		b.disable()
	
	
func _ready():
	SnakeProps.UM = self
	disable_buttons()
