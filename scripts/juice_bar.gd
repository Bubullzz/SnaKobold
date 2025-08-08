extends VBoxContainer

func update_bar_shape() -> void:
    var ratio = float(SnakeProps.max_juice) / float(SnakeProps.juice_update_thresh)

    var trans_time = 0.5
    var tween_1 = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    var tween_2 = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    var tween_3 = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween_1.tween_property(%JuiceBar, "max_value", SnakeProps.max_juice, trans_time)
    tween_2.tween_property(%JuiceBar, "size_flags_stretch_ratio", ratio, trans_time)
    tween_3.tween_property(%FreeSpace, "size_flags_stretch_ratio", 1 - ratio, trans_time)


func update_bar_value() -> void:
    var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
    tween.tween_property(%JuiceBar, "value", SnakeProps.juice, 0.5)

func _ready() -> void:
    SnakeProps.JuiceBar = self