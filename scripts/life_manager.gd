extends Node

@export var HealthShader: ColorRect

var max_health = 100
var health = max_health
var health_tween: Tween
var health_delta = 35

func on_collision():
	if health_tween:
		health_tween.stop()
	health_tween = get_tree().create_tween()
	health_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if health - health_delta < 0:
		Signals.game_lost.emit()
		print("life manager emmited game lost signal")
		health_tween.tween_property(self, "health", -50, 3.) # make the shader take full screen on death       
		return
	health_tween.tween_property(self, "health", health - health_delta, .4)

	health_tween.set_ease(Tween.EASE_IN)
	health_tween.tween_property(self, "health", max_health, 8)
	
func _ready() -> void:
	Signals.on_collision.connect(on_collision)

func _process(_delta: float) -> void:
	HealthShader.material.set_shader_parameter("level", 1 - health/100.)
