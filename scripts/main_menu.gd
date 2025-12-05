extends CanvasLayer

@export var BlurContainer: SubViewportContainer
@export var inital_blur = 6.
@export var high_blur = 10.
@export var high_time = 1.
@export var low_time = 1.


func _ready():
	BlurContainer.material.set_shader_parameter("scale", inital_blur)


func _on_button_button_up() -> void:
	%StartButton.disabled = true
	
	var blur_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	blur_tween.tween_method(func(v): BlurContainer.material.set_shader_parameter("scale", v), inital_blur,high_blur, high_time)
	blur_tween.set_ease(Tween.EASE_IN_OUT)
	blur_tween.tween_method(func(v): BlurContainer.material.set_shader_parameter("scale", v), high_blur,-.001, low_time)
	
	var transparency_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	transparency_tween.tween_property(%MenuLayout, "modulate:a", 0., 1.)
	transparency_tween.finished.connect(func():%MenuLayout.visible = false)
	var scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(%MenuLayout, "scale", Vector2(3.,3.), 1.)
