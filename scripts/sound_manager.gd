extends Node

class_name SoundManager

func get_random_pitch(min_, max_):
	var diff = max_ - min_
	return min_ + randf() * diff

func random_pitch_play(player, min_=0.98, max_=1.02):
	player.pitch_scale = get_random_pitch(min_, max_)
	player.play()

func apple_eaten_sound(_x):
	random_pitch_play($AppleEaten, 0.9, 1.2)
	
func jump_sound():
	random_pitch_play($Jump)

func glass_break():
	random_pitch_play($GlassBreak)

func apple_falling_sound():
	random_pitch_play($AppleFalling)

func full_sound():
	random_pitch_play($Full)
	
func combo_break_sound():
	random_pitch_play($ComboBreak)

func rumbling_sound():
	random_pitch_play($Rumbling)

func juice_eaten(_x):
	if SnakeProps.juice_combo > 10:
		var pitch2 = 1.5
		$JuiceEaten2.pitch_scale = pitch2
		$JuiceEaten2.play()
		await get_tree().create_timer(.1).timeout
	var pitch1 = 1 + SnakeProps.juice_combo * 0.1
	$JuiceEaten1.pitch_scale = pitch1
	$JuiceEaten1.play()

func open_upgrade_sound():
	random_pitch_play($UpgradesOpen, 0.9, 1.1)

func close_upgrade_sound():
	random_pitch_play($UpgradesClose, 0.9, 1.1)

func bump_sound():
	var h = SnakeProps.LifeManager.health
	var m_h = SnakeProps.LifeManager.max_health
	var max_db = 15.
	$Bump.volume_db = lerp(max_db, 5., h/m_h)
	$Bump.pitch_scale = lerp(1., .7, h/m_h)
	random_pitch_play($Bump)
	

func reset_combo_sequence(combo: int):
	for i in range(0, combo + 2, 2):
		$JuiceEaten2.pitch_scale = 1 + (combo - i) * 0.1
		$JuiceEaten2.play()
		await get_tree().create_timer(.1).timeout 

func game_over_sound():
	$GameOver.play()

func _ready():
	SnakeProps.Audio = self
	Signals.apple_eaten.connect(apple_eaten_sound)
	Signals.juice_eaten.connect(juice_eaten)
	Signals.on_collision.connect(bump_sound)
	Signals.game_lost.connect(game_over_sound)
