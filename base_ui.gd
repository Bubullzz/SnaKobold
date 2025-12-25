extends CanvasLayer

func _ready():
	Signals.juice_combo_updated.connect(_on_juice_combo_updated)
	SnakeProps.BaseUI = self

func _on_juice_combo_updated(old, new):
	var step = 1
	if old > new:
		step = -1
	for i in range(old + step, new + step, step):
		%ComboIndicator.text = "x%d" % [i]
		await get_tree().create_timer(0.1).timeout
