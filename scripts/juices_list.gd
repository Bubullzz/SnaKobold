extends Node

enum STATE {PAUSED, PLAYING}
var state: STATE = STATE.PLAYING
func _ready():
	SnakeProps.JuicesList = self

func pause():
	state = STATE.PAUSED
	for child in self.get_children():
		child.pause()

func play():
	state = STATE.PLAYING
	for child in self.get_children():
		child.play()


func _on_child_entered_tree(juice: Node) -> void:
	if state == STATE.PAUSED:
		await get_tree().create_timer(0.01).timeout
		juice.pause()
