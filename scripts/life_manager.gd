extends Node

@export var HealthShader: ColorRect

var max_health: float = 100.
var health = max_health
var health_tween: Tween
var health_delta = 35

func on_collision():
	if health_tween:
		health_tween.stop()
	health_tween = get_tree().create_tween()
	health_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if health - health_delta < -20:
		Signals.game_lost.emit()
		return
	health_tween.tween_property(self, "health", health - health_delta, .4)

	await get_tree().create_timer(5.).timeout
	if health_tween:
		health_tween.stop()
	health_tween = get_tree().create_tween()
	health_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	health_tween.tween_property(self, "health", max_health, (max_health - health) / max_health * 12.)

func stop():
	if health_tween:
		health_tween.stop()
	health_tween = get_tree().create_tween()
	health_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	health_tween.tween_property(self, "health", -50, 3.) # make the shader take full screen on death       

	
func _ready() -> void:
	Signals.on_collision.connect(on_collision)

func _process(_delta: float) -> void:
	HealthShader.material.set_shader_parameter("level", 1 - health/100.)
