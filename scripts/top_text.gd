extends Control

class_name TopText
var entry_time: float = 2.

static func instantiate(text: String, time: float = 2.):
	var pop_up: TopText = load("res://scenes/top_text.tscn").instantiate()
	pop_up.initialize(text, time)
	return pop_up
	
func initialize(text: String, time: float):
	$MarginContainer/Text.text = text
	self.modulate.a = 0.
	await create_tween().set_trans(Tween.TRANS_CIRC).tween_property(self, "modulate:a", 1., entry_time).finished
	await get_tree().create_timer(time).timeout
	await create_tween().tween_property(self, "modulate:a", 0., entry_time).finished
	self.queue_free()
