extends Upgrade

@export var GrayScaledRect: ColorRect
@export var upgrades_manager: Node
@export var main_cam: Camera2D
var add_amount = 3
var owned = false
@export var slowing_factor : float
@export var snake_speed_slowdown_time : float
@export var start_shockwave_time : float
@export var stop_shockwave_time : float
var tweeners: Array[Tween] = []
var is_slowing = false
var price_per_second = 200

func _ready():
	title = "Aura Farmer"
	
func get_text()->String:
	return "Slow down time by pressing 'Q' in exchange of Juice !"


func on_selected():
	owned = true
	self.get_parent().remove_child(self)
	SnakeProps.OwnedUpgradesList.add_child(self)
	
func _process(delta: float) -> void:
	if !owned:
		return
	if Input.is_action_just_pressed("Action"):
		$TimeBeforeStart.start()
	if is_slowing and (!SnakeProps.consume_juice(delta * price_per_second) or !Input.is_action_pressed("Action")):
		is_slowing = false
		reset_everything()


func reset_everything():
	$TimeBeforeStart.stop()
	
	SnakeProps.JuicesList.play()
	
	for t:Tween in tweeners:
		if t:
			t.kill()
	
	if !upgrades_manager.upgrading:
		var t1 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		t1.tween_property(SnakeProps.SM, "speed", SnakeProps.SM.target_speed, snake_speed_slowdown_time)
		tweeners.append(t1)
	
	var t2 = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	var last_shader_value = GrayScaledRect.material.get_shader_parameter("first")
	t2.tween_method(func(v): GrayScaledRect.material.set_shader_parameter("first", v), last_shader_value,-0.1, stop_shockwave_time)

	print("reversing everything due to bullet_time")
	

func _on_time_before_start_timeout() -> void:
	print("starting bullet_time")
	
	SnakeProps.JuicesList.pause()
	
	is_slowing = true
	var t1 = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t1.tween_property(SnakeProps.SM, "speed", SnakeProps.SM.target_speed / slowing_factor, snake_speed_slowdown_time)
	tweeners.append(t1)
	
	GrayScaledRect.material.set_shader_parameter("HeadPosInCamera", get_starting_pos())
	print(get_starting_pos())
	var t2 = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t2.tween_method(func(v): GrayScaledRect.material.set_shader_parameter("first", v), -0.1,1.0, start_shockwave_time)
	tweeners.append(t2)


func get_starting_pos()-> Vector2:
	return Vector2(0.8,0.5)
