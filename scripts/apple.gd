extends Node2D

class_name Apple

static func instantiate(context, base: Vector2i):
    var SM = context.get_node("%SnakeManager")
    var EM = context.get_node("%EnvironmentManager")
    var MAP = context.get_node("%WallsLayer")
    var apples_dict = context.get_node("/root/MainGame").apples_pos
    var instance = load("res://scenes/apple.tscn").instantiate()
    var spawn_height = 15
    var spawn_width = 20
    var apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
    while apples_dict.has(apple_pos) or \
                SM.is_snake(apple_pos) or \
                EM.is_wall(apple_pos) or \
                false:
        spawn_height += 1
        spawn_width += 1
        apple_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
        if spawn_height > 50 or spawn_width > 50:
            print("Failed to find a position for apple, giving uppppp")
            return
    print("Apple spawned at ", apple_pos)
    print("base", base)
    instance.position = MAP.map_to_local(apple_pos)
    apples_dict[apple_pos] = true
    context.get_tree().root.add_child(instance)


func _on_area_2d_area_entered(area:Area2D) -> void:
    var SM = area.get_node("%SnakeManager")
    SM.growth += 1
    instantiate(area, SM.body[0])
    var apple_eat_particles_1 = preload("res://particles/apple_eat_particles.tscn").instantiate()
    apple_eat_particles_1.global_position = global_position
    apple_eat_particles_1.start()
    get_tree().root.add_child(apple_eat_particles_1)
    queue_free()
