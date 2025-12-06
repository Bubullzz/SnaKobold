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

func _ready():
	SnakeProps.Audio = self
	Signals.apple_eaten.connect(apple_eaten_sound)
