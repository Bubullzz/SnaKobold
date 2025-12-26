extends Control

func _ready() -> void:
	$Texts.position = Vector2(0,1080)
	await get_tree().create_timer(48.).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(delta: float) -> void:
	var speed = 100.
	$Texts.position.y -= delta * speed
