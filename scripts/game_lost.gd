extends Control

@export var Stats: Stats

func update():
	%NbApplesEaten.text += str(Stats.nb_apples_eaten)
	%TotalJuiceGathered.text += str(Stats.total_juice_gathered)
	%NbJuiceSpilled.text += str(Stats.nb_juice_spilled)
	%MaxCombo.text += str(Stats.max_combo)
	%NumberOfCollisions.text += str(Stats.number_of_collisions)
	%FinalLength.text += str(len(SnakeProps.SM.body))

func appear():
	update()
	modulate.a = 0
	var t = get_tree().create_tween()
	t.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1, 2)
	%RestartButton.grab_focus()
	
func _on_restart_button_button_down() -> void:
	Signals.restart.emit()
