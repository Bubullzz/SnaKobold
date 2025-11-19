extends Apple

class_name GoldenApple

static var last_gapple_eaten = -99999
static var time_between_two_spawns = 30 * 1000


static func is_gapple_spawn()-> bool:
	if !SnakeProps.OwnedUpgradesList.has_node("./CollectApplesUpgrade"):
		return false
	if Time.get_ticks_msec() - last_gapple_eaten < time_between_two_spawns:
		return false
	if randi() % int(len(SnakeProps.ApplesList.get_children()) * .8 + 10) != 0:
		return false
	print(Time.get_ticks_msec() - last_gapple_eaten)
	print(time_between_two_spawns)
	last_gapple_eaten = Time.get_ticks_msec()
	return true

func collect() -> void:
	if !collecting:
		last_gapple_eaten = Time.get_ticks_msec()
		collecting = true
		Signals.apple_eaten.emit(self)
		Signals.golden_apple_eaten.emit(self)
		var SM = SnakeProps.SM
		SnakeProps.growth += 1
		Apple.instantiate(SnakeProps.SM.body[0])
		var apple_eat_particles_1 = preload("res://particles/apple_eat_particles.tscn").instantiate()
		apple_eat_particles_1.global_position = global_position
		apple_eat_particles_1.start()
		get_tree().root.add_child(apple_eat_particles_1)
		SnakeProps.eatables_pos.erase(tiles_pos)
		
		queue_free()
	
func _on_area_2d_area_entered(_area:Area2D) -> void:
	collect()


func handle_attraction(_delta):
	if is_attracted:
		pass



func _process(_delta: float) -> void:
	var random_value = global_position.x * global_position.y 
	var s = sin(Time.get_ticks_msec() / 3000.0 * 2.0 * PI + random_value * 9999)
	s = s / 2 + 0.5
	$AppleSprite.position.y = -s * 2
	
	handle_attraction(_delta)


func animate_entry():
	$ShadowSprite.scale= Vector2(0,0)
	$AppleSprite.scale = Vector2(0,0)
	
	var t1 = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var t2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	t1.tween_property($AppleSprite, "scale", Vector2(1,1), 1)
	t2.tween_property($ShadowSprite, "scale", Vector2(1,1), .2)

func _ready() -> void:
	#$AppleSprite.set_instance_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)
	animate_entry()
	
