extends Control

@export var stats: Stats

func update():
	%NbApplesEaten.text += str(stats.nb_apples_eaten)
	%TotalJuiceGathered.text += str(stats.total_juice_gathered)
	%NbJuiceSpilled.text += str(stats.nb_juice_spilled)
	%MaxCombo.text += str(stats.max_combo)
	%NumberOfCollisions.text += str(stats.number_of_collisions)
	%FinalLength.text += str(len(SnakeProps.SM.body))

func appear():
	update()
	modulate.a = 0
	var t = get_tree().create_tween()
	t.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 1, 2)

func _on_restart_button_button_up() -> void:
	$ClickUp.play()
	Signals.restart.emit()


func _on_restart_button_button_down() -> void:
	$ClickDown.play()


func _on_restart_button_mouse_entered() -> void:
	$Hover.play()
