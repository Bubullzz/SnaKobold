extends Node2D

class_name Juice

var base_wait_time = SnakeProps.juice_wait_time
var nb_frames = 16
var last_frame_duration = 4
var tot_frames = nb_frames + last_frame_duration - 1
var fps = tot_frames / base_wait_time
var max_spill_time = 8
var spill_tween : Tween
var transparency_tween : Tween
var start = Time.get_ticks_msec()
var tiles_pos: Vector2i
var SM

var end_animation_time = 0.5 # Time to make the juice disappear
var spill_time = base_wait_time - end_animation_time

static func instantiate(context, base: Vector2i):
	var LOC_SM = context.get_node("%SnakeManager")
	var EM = context.get_node("%EnvironmentManager")
	var MAP = context.get_node("%WallsLayer")
	var instance: Juice = load("res://scenes/juice.tscn").instantiate().duplicate()
	instance.get_node("JuiceDespawnTimer").wait_time = instance.base_wait_time
	instance.get_node("JuiceEndAnimationTimer").wait_time = instance.base_wait_time - instance.end_animation_time
	instance.get_node("JuiceAnimated").speed_scale = instance.fps
	instance.get_node("JuiceAnimated").frame = 0
	instance.get_node("JuiceAnimated").play()
	instance.scale.x = 0
	#instance.create_tween()
	var t = instance.create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(instance, "scale:x", 1, .4)
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
	SnakeProps.JuicesList.add_child(instance)


func _on_collision_zone_area_entered(area:Area2D) -> void:
	SnakeProps.eatables_pos.erase(tiles_pos)
	call_deferred("instantiate", area, SM.body[0])
	var jc = SnakeProps.juice_combo
	SnakeProps.on_juice_consumed()
	PopUpText.spawn_juice_popup(self, "x%d" % [jc], global_position, jc)
	queue_free()

func start_transparency_tween():
	transparency_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	transparency_tween.tween_method(func(v): $ShaderSpill.material.set_shader_parameter("transparency", v), 1.0,0.0,max_spill_time)
	await get_tree().create_timer(max_spill_time).timeout
	queue_free()
	
func _on_timer_timeout() -> void: # The juice is spilled
	Signals.juice_spilled.emit(self)
	start_transparency_tween()
	SnakeProps.eatables_pos.erase(tiles_pos)
	instantiate(SM, SM.body[0])
	var jc = SnakeProps.juice_combo # Stocking it before the potential reset
	if SnakeProps.on_juice_spilled(): # Reseted combo
		if jc > SnakeProps.min_juice_combo + 3:
			var t = preload("res://scenes/pop_up_text.tscn").instantiate()
			t.initialize_combo_break(global_position, jc)
			get_tree().root.add_child(t)
	else:
		if jc > SnakeProps.min_juice_combo + 3:
			var t = preload("res://scenes/pop_up_text.tscn").instantiate()
			t.initialize("%d misses left !" % [SnakeProps.max_allowed_misses - SnakeProps.nb_juices_missed], global_position)
			get_tree().root.add_child(t)
	
	$CollisionZone.queue_free()


func _ready() -> void:
	$ShaderSpill.material.set_shader_parameter("threshold", 0)
	spill_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	spill_tween.tween_method(func(v): $ShaderSpill.material.set_shader_parameter("threshold", v), 0.0,1.0,spill_time)
	$ShaderSpill.material.get_shader_parameter("perlin").noise.seed = randi()


func _on_juice_end_animation_timer_timeout() -> void:
	const OSCILLATIONS := 5
	const DISTANCE:= 1.5
	var t := create_tween()
	var init_pos = $JuiceAnimated.position.x
	t.tween_method(func(x): $JuiceAnimated.position.x = init_pos + sin(x * 2) * DISTANCE, 0.0, PI * OSCILLATIONS, end_animation_time)

	var t2 := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	t2.tween_property($JuiceAnimated, "modulate", Color(1, 1, 1, 0), end_animation_time)

func pause():
	$JuiceDespawnTimer.paused = true
	$JuiceEndAnimationTimer.paused = true
	if spill_tween:
		spill_tween.pause()
	if transparency_tween:
		transparency_tween.pause()
	$JuiceAnimated.pause()

func play():
	$JuiceDespawnTimer.paused = false
	$JuiceEndAnimationTimer.paused = false
	if spill_tween and spill_tween.is_valid():
		spill_tween.play()
	if transparency_tween and transparency_tween.is_valid():
		transparency_tween.play()
	$JuiceAnimated.play()
