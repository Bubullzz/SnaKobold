extends Control

class_name TopText
var entry_time: float = 2.

static func instantiate(text: String, time: float = 2.):
	var pop_up: TopText = load("res://scenes/top_text.tscn").instantiate()
	pop_up.initialize(text, time)
	SnakeProps.BaseUI.add_child(pop_up)
	
func initialize(text: String, time: float):
	$sound.pitch_scale = .7 + randf() * .3
	$MarginContainer/Text.text = text
	self.modulate.a = 0.
	await create_tween().set_trans(Tween.TRANS_CIRC).tween_property(self, "modulate:a", 1., entry_time).finished
	await get_tree().create_timer(time).timeout
	await create_tween().tween_property(self, "modulate:a", 0., entry_time).finished
	
	# Freeing only after some time to make sure sound has time to finish
	await get_tree().create_timer(5.).timeout 
	self.queue_free()
