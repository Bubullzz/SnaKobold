extends Node

func _ready():
	SnakeProps.JuicesList = self

func pause():
	for child in self.get_children():
		child.pause()

func play():
	for child in self.get_children():
		child.play()
