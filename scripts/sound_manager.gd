extends Node

class_name SoundManager

func get_random_pitch(min_=0.95, max_=1.05):
	var diff = max_ - min_
	return min_ + randf() * diff

func random_pitch_play(player: AudioStreamPlayer2D, min_=0.95, max_=1.05):
	player.pitch_scale = get_random_pitch(min_, max_)
	player.play()

func apple_eaten_sound(_x):
	random_pitch_play($AppleEaten)

func apple_falling_sound():
	random_pitch_play($AppleFalling)

func full_sound():
	random_pitch_play($Full)
	
func combo_break_sound():
	random_pitch_play($ComboBreak)

func _ready():
	SnakeProps.Audio = self
	Signals.apple_eaten.connect(apple_eaten_sound)
