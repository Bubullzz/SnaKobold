extends CanvasLayer

func _ready():
	SnakeProps.juice_combo_updated.connect(_on_juice_combo_updated)

func _on_juice_combo_updated(value):
	%ComboIndicator.text = "x%d" % [value]
