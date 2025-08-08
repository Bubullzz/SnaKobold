extends Node2D

class_name Apple

static func instantiate(context, base: Vector2i):
    var SM = context.get_node("%SnakeManager")
    var EM = context.get_node("%EnvironmentManager")
    var MAP = context.get_node("%WallsLayer")
    var apples_dict = context.get_node("/root/MainGame").eatables_pos
    var instance = load("res://scenes/apple.tscn").instantiate()
    var spawn_height = 15
    var spawn_width = 20
    var apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
    while apples_dict.has(apple_pos) or \
                SM.is_snake(apple_pos) or \
                EM.is_wall(apple_pos) or \
                ! SM.check_accessible(apple_pos):
        spawn_height += 1
        spawn_width += 1
        apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)

    instance.position = MAP.map_to_local(apple_pos)
    apples_dict[apple_pos] = context.get_node("/root/MainGame").EAT.APPLE
    context.get_tree().root.add_child(instance)


func _on_area_2d_area_entered(area:Area2D) -> void:
    var SM = area.get_node("%SnakeManager")
    SnakeProps.growth += 1
    call_deferred("instantiate", area, SM.body[0])
    var apple_eat_particles_1 = preload("res://particles/apple_eat_particles.tscn").instantiate()
    apple_eat_particles_1.global_position = global_position
    apple_eat_particles_1.start()
    get_tree().root.add_child(apple_eat_particles_1)
    queue_free()

func _process(_delta: float) -> void:
    var random_value = global_position.x * global_position.y 
    var s = sin(Time.get_ticks_msec() / 3000.0 * 2.0 * PI + random_value * 9999)
    s = s / 2 + 0.5
    $AppleSprite.position.y = -s * 2