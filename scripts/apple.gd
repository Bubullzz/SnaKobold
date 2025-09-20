extends Node2D

class_name Apple

var is_attracted = false
var tiles_pos: Vector2i
var collecting = false

static func instantiate(base: Vector2i):
	var SM = SnakeProps.SM
	var EM = SnakeProps.GameTiles.find_child("EnvironmentManager")
	var MAP = SnakeProps.GameTiles.find_child("WallsLayer")
	var AL = SnakeProps.ApplesList
	
	var instance: Apple = load("res://scenes/apple.tscn").instantiate()
	if GoldenApple.is_gapple_spawn():
		instance = load("res://scenes/golden_apple.tscn").instantiate()
	var spawn_height = 15
	var spawn_width = 20
	var apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
	while SnakeProps.eatables_pos.has(apple_pos) or \
				SM.is_snake(apple_pos) or \
				EM.is_wall(apple_pos) or \
				! SM.check_accessible(apple_pos):
		spawn_height += 1
		spawn_width += 1
		apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
	
	instance.position = MAP.map_to_local(apple_pos)
	instance.tiles_pos = apple_pos
	SnakeProps.eatables_pos[apple_pos] = instance
	AL.add_child(instance)

func collect() -> void:
	if !collecting:
		collecting = true
		#print("collected", self.tiles_pos)
		Signals.apple_eaten.emit(self)
		var SM = SnakeProps.SM
		SnakeProps.growth += 1
		#call_deferred("instantiate", SM.body[0])
		Apple.instantiate(SnakeProps.SM.body[0])
		var apple_eat_particles_1 = preload("res://particles/apple_eat_particles.tscn").instantiate()
		apple_eat_particles_1.global_position = global_position
		apple_eat_particles_1.start()
		get_tree().root.add_child(apple_eat_particles_1)
		SnakeProps.eatables_pos.erase(tiles_pos)
		queue_free()
	
func _on_area_2d_area_entered(_area:Area2D) -> void:
	collect()


func handle_attraction(delta):
	var speed = 10
	if is_attracted:
		var direction = SnakeProps.SM.get_head_world_pos() - self.position
		position += direction * speed * delta



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
	
