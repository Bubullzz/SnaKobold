extends Node2D

class_name Apple

var is_attracted = false
var tiles_pos: Vector2i
var collecting = false
var spawning = false

static func instantiate(base: Vector2i, is_payed: bool):
	var SM = SnakeProps.SM
	var EM = SnakeProps.GameTiles.find_child("EnvironmentManager")
	
	var instance: Apple
	if GoldenApple.is_gapple_spawn():
		instance = load("res://scenes/golden_apple.tscn").instantiate()
	else:
		instance = load("res://scenes/apple.tscn").instantiate()
		
	var spawn_height = 15
	var spawn_width = 20
	var nb_tries = 0
	var allowed_tries = 200
	
	var apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
	while nb_tries < allowed_tries and \
				(SnakeProps.eatables_pos.has(apple_pos) or \
				SM.is_snake(apple_pos) or \
				EM.is_wall(apple_pos) or \
				! SM.check_accessible(apple_pos)):
		nb_tries+=1
		spawn_height += 1
		spawn_width += 1
		apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
	if nb_tries >= allowed_tries: print("failed to spawn apple, too many triess")
	else:
		var final_pos = SnakeProps.GameTiles.tile_pos_to_global_pos(apple_pos)
		instance.position = final_pos
		SnakeProps.eatables_pos[apple_pos] = instance
		instance.tiles_pos = apple_pos
		if is_payed:
			instance.falling_spawn()
		else:
			instance.simple_spawn()
		SnakeProps.ApplesList.call_deferred("add_child", instance)
		

func falling_spawn():
	spawning = true
	SnakeProps.Audio.apple_falling_sound()
	$AppleSprite.position = Vector2(0,-2000)
	$AppleSprite.z_index += 1000 # print it over everything
	var fall_time = 2.
	SnakeProps.get_tree().create_timer(fall_time).timeout.connect(func (): spawning = false)
	SnakeProps.get_tree().create_timer(fall_time - .1).timeout.connect(func (): $AppleSprite.z_index -= 1000)
	var apple_sprite_pos_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	apple_sprite_pos_tween.tween_property($AppleSprite, "position", Vector2(0,0), fall_time)

	$ShadowSprite.scale = Vector2(0,0)
	var shadow_scale_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	shadow_scale_tween.tween_property($ShadowSprite, "scale", Vector2(1,1), fall_time)

func simple_spawn():
	
	$ShadowSprite.scale= Vector2(0,0)
	$AppleSprite.scale = Vector2(0,0)
	
	var t1 = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var t2 = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	t1.tween_property($AppleSprite, "scale", Vector2(1,1), 1)
	t2.tween_property($ShadowSprite, "scale", Vector2(1,1), .2)
	
func collect() -> void:
	if !collecting:
		collecting = true
		SnakeProps.eatables_pos.erase(tiles_pos)
		Signals.apple_eaten.emit(self)
		var SM = SnakeProps.SM
		SnakeProps.growth += 1
		Apple.instantiate(SnakeProps.SM.body[0], false)
		var apple_eat_particles_1 = preload("res://particles/apple_eat_particles.tscn").instantiate()
		apple_eat_particles_1.position = position
		apple_eat_particles_1.start()
		var t = get_tree()
		if t != null:
			SnakeProps.Overlays.add_child(apple_eat_particles_1)
		else:
			print("did not find a tree on apple collection, maybe i m null ?")
		queue_free()
	
func _on_area_2d_area_entered(_area:Area2D) -> void:
	collect()


func handle_attraction(delta):
	var speed = 10
	if is_attracted:
		var direction = SnakeProps.SM.get_head_world_pos() - self.position
		position += direction * speed * delta



func _process(_delta: float) -> void:
	if !spawning:
		var random_value = global_position.x * global_position.y 
		var s = sin(Time.get_ticks_msec() / 3000.0 * 2.0 * PI + random_value * 9999)
		s = s / 2 + 0.5
		$AppleSprite.position.y = -s * 2
	
	handle_attraction(_delta)

func _ready() -> void:
	return
