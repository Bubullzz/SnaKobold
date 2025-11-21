extends Node2D

var nb_apples_spawned = 20

func on_collect():
	print("basket collected")
	var scale_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	scale_tween.tween_property(self, "scale", Vector2(0,0), .07)
	for i in range(nb_apples_spawned):
		Apple.instantiate(SnakeProps.SM.body[0], true)
		await get_tree().create_timer(.02).timeout
	SnakeProps.UM.start_upgrade_sequence()
	queue_free()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	on_collect()
