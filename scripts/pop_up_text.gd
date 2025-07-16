extends Node2D

class_name PopUpText

@export var time_alive : float = 1.0
var direction : Vector2 
@export var speed : float = 100.0
@export var juice_text_color : Color
@export var apple_text_color : Color

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

    
func initialize_apple(text: String, global_pos: Vector2) -> void:
    initialize(text, global_pos)
    $Text.label_settings.font_color = apple_text_color
    $Text.label_settings.outline_color = Color(1,1,1,1)
    $Text.label_settings.font_size = 30
    $Text.label_settings.outline_size = 0
    speed = 20


func initialize_combo_break(global_pos: Vector2, combo) -> void:
    initialize("COMBO\nBREAK", global_pos)
    $Text.label_settings.font_color = Color(1, 1,1, 1)
    $Text.label_settings.outline_color = Color(0, 0, 0, 1)
    $Text.label_settings.outline_size = 2
    $Text.label_settings.font_size = 10
    $Text.label_settings.font_size += combo * 4
    speed = 0

func _process(delta: float) -> void:
    position += direction * speed * delta
    $Text.modulate.a = clamp($Text.modulate.a - delta / time_alive, 0, 1)


func _on_timer_timeout() -> void:
    queue_free()


static func juice2(text: String, global_pos: Vector2, combo: int) -> PopUpText:
    var instance = preload("res://scenes/pop_up_text.tscn").instantiate()
    instance.initialize_juice(text, global_pos, combo)
    return instance
