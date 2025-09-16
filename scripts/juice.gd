extends Node2D

class_name Juice

var base_wait_time = 3.5
var nb_frames = 16
var last_frame_duration = 4
var tot_frames = nb_frames + last_frame_duration - 1
var fps = tot_frames / base_wait_time
var max_spill_time = 8
var start = Time.get_ticks_msec()
var tiles_pos: Vector2i
var SM

var end_animationT_time = 0.5 # Time to make the juice disappear

static func instantiate(context, base: Vector2i):
	var LOC_SM = context.get_node("%SnakeManager")
	var EM = context.get_node("%EnvironmentManager")
	var MAP = context.get_node("%WallsLayer")
	var instance: Juice = load("res://scenes/juice.tscn").instantiate().duplicate()
	instance.get_node("JuiceDespawnTimer").wait_time = instance.base_wait_time
	instance.get_node("JuiceEndAnimationTimer").wait_time = instance.base_wait_time - instance.end_animationT_time
	instance.get_node("SpillingStopper").wait_time = instance.base_wait_time - instance.end_animationT_time - 0.2
	instance.get_node("JuiceAnimated").speed_scale = instance.fps
	instance.get_node("JuiceAnimated").frame = 0
	instance.get_node("JuiceAnimated").play()
	instance.SM = LOC_SM
	var spawn_height = 4
	var spawn_width = 4
	var juice_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
	while SnakeProps.eatables_pos.has(juice_pos) or \
				LOC_SM.is_snake(juice_pos) or \
				EM.is_wall(juice_pos) or \
				! LOC_SM.check_accessible(juice_pos):
		spawn_height += 1
		spawn_width += 1
		juice_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)

	
	instance.position = MAP.map_to_local(juice_pos)
	instance.tiles_pos = juice_pos
	SnakeProps.eatables_pos[juice_pos] = instance
	context.get_tree().root.add_child(instance)


func _on_collision_zone_area_entered(area:Area2D) -> void:
	SnakeProps.eatables_pos.erase(tiles_pos)
	call_deferred("instantiate", area, SM.body[0])
	SnakeProps.on_juice_consumed()
	var jc = SnakeProps.juice_combo
	PopUpText.spawn_juice_popup(self, "x%d" % [jc], global_position, jc)
	queue_free()


func _on_timer_timeout() -> void: # The juice is spilled
	SnakeProps.eatables_pos.erase(tiles_pos)
	instantiate(SM, SM.body[0])
	var jc = SnakeProps.juice_combo # Stocking it before the potential reset
	if SnakeProps.on_juice_spilled(): # Reseted combo
		if jc > 3:
			var t = preload("res://scenes/pop_up_text.tscn").instantiate()
			t.initialize_combo_break(global_position, jc)
			get_tree().root.add_child(t)
	else:
		if jc > 3:
			var t = preload("res://scenes/pop_up_text.tscn").instantiate()
			t.initialize("%d misses left !" % [SnakeProps.max_allowed_misses - SnakeProps.nb_juices_missed], global_position)
			get_tree().root.add_child(t)
	$CollisionZone.queue_free()


func _process(_delta: float) -> void:
	var elapsed = Time.get_ticks_msec() - start
	if elapsed > base_wait_time * 1000: # spilled
		var weight = (elapsed - base_wait_time * 1000) / (max_spill_time * 1000)
		$ShaderSpill.set_instance_shader_parameter("spill_transparency", weight)


func _ready() -> void:
	$ShaderSpill.set_instance_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)
	$ShaderSpill.set_instance_shader_parameter("end_time", -1.)
	$ShaderSpill.set_instance_shader_parameter("base_wait_time", base_wait_time)
	$ShaderSpill.material.get_shader_parameter("perlin").noise.seed = randi()

	$JuiceAnimated.set_instance_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)


func _on_juice_end_animation_timer_timeout() -> void:
	const OSCILLATIONS := 5
	const DISTANCE:= 1.5
	var t := create_tween()
	var init_pos = $JuiceAnimated.position.x
	t.tween_method(func(x): $JuiceAnimated.position.x = init_pos + sin(x * 2) * DISTANCE, 0.0, PI * OSCILLATIONS, end_animationT_time)

	var t2 := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	t2.tween_property($JuiceAnimated, "modulate", Color(1, 1, 1, 0), end_animationT_time)
	


func _on_spilling_stopper_timeout() -> void:
	$ShaderSpill.set_instance_shader_parameter("end_time", Time.get_ticks_msec() / 1000.0 - .2)
