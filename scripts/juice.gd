extends Node2D

class_name Juice

var base_wait_time = 3.5
var nb_frames = 16
var fps = nb_frames / base_wait_time
var max_spill_time = 8
var start = Time.get_ticks_msec()
var SM

static func instantiate(context, base: Vector2i):
    var LOC_SM = context.get_node("%SnakeManager")
    var EM = context.get_node("%EnvironmentManager")
    var MAP = context.get_node("%WallsLayer")
    var apples_dict = context.get_node("/root/MainGame").eatables_pos
    var instance = load("res://scenes/juice.tscn").instantiate().duplicate()
    instance.get_node("Timer").wait_time = instance.base_wait_time
    instance.get_node("JuiceAnimated").speed_scale = instance.fps
    instance.get_node("JuiceAnimated").frame = 0
    instance.get_node("JuiceAnimated").play()
    instance.SM = LOC_SM
    var spawn_height = 4
    var spawn_width = 4
    var juice_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)
    while apples_dict.has(juice_pos) or \
                LOC_SM.is_snake(juice_pos) or \
                EM.is_wall(juice_pos) or \
                ! LOC_SM.check_accessible(juice_pos):
        spawn_height += 1
        spawn_width += 1
        juice_pos = Vector2i(base.x + (randi() % spawn_width) - spawn_width/2, base.y + (randi() % spawn_height) - spawn_height/2)

    instance.position = MAP.map_to_local(juice_pos)
    apples_dict[juice_pos] = true
    apples_dict[juice_pos] = context.get_node("/root/MainGame").EAT.JUICE
    context.get_tree().root.add_child(instance)


func _on_collision_zone_area_entered(area:Area2D) -> void:
    call_deferred("instantiate", area, SM.body[0])
    SM.update_juice(100 * SM.juice_combo)
    var jc = SM.juice_combo
    PopUpText.spawn_juice_popup(self, "+%d" % [100 * jc], global_position, jc)
    SM.juice_combo = min(jc + 1, SM.max_juice_combo)
    queue_free()


func _on_timer_timeout() -> void:
    instantiate(SM, SM.body[0])
    if SM.juice_combo > 4:
        var t = preload("res://scenes/pop_up_text.tscn").instantiate()
        t.initialize_combo_break(global_position, SM.juice_combo)
        get_tree().root.add_child(t)
    SM.juice_combo = 1
    $JuiceAnimated.visible = false
    $CollisionZone.queue_free()
    $ShaderSpill.set_instance_shader_parameter("end_time", Time.get_ticks_msec() / 1000.0 - .2)


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
