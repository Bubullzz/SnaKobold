extends Node2D

class_name PopUpText

@export var time_alive : float = 1.0
var direction : Vector2 
@export var speed : float = 100.0
@export var juice_text_color : Color
@export var apple_text_color : Color
@export var apple_outline_color : Color

var combo_break_texts = [
	"COMBO\nBREAK",
	"COMBO\nBREAK",
	"COMBO\nBREAK",
	"COMBO\nBREAK",
	"COMBO\nBREAK",
	"Uh Oh\n:(",
	"Skill\nIssue",
	"SPILLED\nEVERYWHERE",
]
func initialize(text: String, global_pos: Vector2) -> void:
	$Text.label_settings = $Text.label_settings.duplicate()
	direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	$Text.text = text
	$Text.label_settings.font_color = Color(1, 1, 1, 1)
	$Text.label_settings.outline_color = Color(0, 0, 0, 1)
	$Text.label_settings.outline_size = 4
	position = global_pos
	$Text.show()
	$Timer.wait_time = time_alive

func initialize_juice(text: String, global_pos: Vector2, combo: int) -> void:
	initialize(text, global_pos)
	$Text.modulate = juice_text_color
	$Text.label_settings.font_size = 10
	$Text.label_settings.font_size += combo * 3
	$Text.label_settings.outline_color = apple_outline_color
	$Text.label_settings.outline_size = 4 + combo/4
	

	
func initialize_apple(text: String, global_pos: Vector2) -> void:
	initialize(text, global_pos)
	$Text.label_settings.font_color = apple_text_color
	$Text.label_settings.outline_color = apple_outline_color
	$Text.label_settings.font_size = 50
	$Text.label_settings.outline_size = 12
	speed = 20


func initialize_combo_break(global_pos: Vector2, combo) -> void:
	initialize(combo_break_texts[randi() % len(combo_break_texts)], global_pos)
	SnakeProps.Audio.combo_break_sound()
	$Text.label_settings.font_color = Color(1, 1,1, 1)
	$Text.label_settings.outline_color = apple_outline_color
	$Text.label_settings.outline_size = 10
	$Text.label_settings.font_size = 10
	$Text.label_settings.font_size += combo * 4
	speed = 0

func _process(delta: float) -> void:
	position += direction * speed * delta
	speed *= 0.98
	$Text.modulate.a = clamp($Text.modulate.a - delta / time_alive, 0, 1)


func _on_timer_timeout() -> void:
	queue_free()


static func spawn_juice_popup(context: Node, text: String, global_pos: Vector2, combo: int) -> void:
	var instance = preload("res://scenes/pop_up_text.tscn").instantiate()
	instance.initialize_juice(text, global_pos, combo)
	SnakeProps.Overlays.add_child(instance)

static func spawn_apple_popup(context: Node, text: String, global_pos: Vector2) -> void:
	var instance = preload("res://scenes/pop_up_text.tscn").instantiate()
	instance.initialize_apple(text, global_pos)
	SnakeProps.Overlays.add_child(instance)
