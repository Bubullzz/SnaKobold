extends Camera2D

@export var advance : int = 2
@export var speed_factor : float = 10
var zoom_k : float = 5
var last_dir_change = 0
var last_dir = Direction.DIR.RIGHT

var tmp_zoom = 0
var tmp_pos = Vector2()
var tmp_lerp_speed = 0.6
var tmp_window = -1
var tmp_elapsed = 0

var shake_strength: float = 2.0
var shake_fade: float = 5
var rng = RandomNumberGenerator.new()
var curr_shake_strength: float = 0.0


func set_both_zoom(value : float) -> void:
    zoom.x = value
    zoom.y = value

func start_shake() -> void:
    curr_shake_strength = shake_strength


func random_offset() -> Vector2:
    return Vector2(rng.randf_range(-curr_shake_strength, curr_shake_strength), rng.randf_range(-curr_shake_strength, curr_shake_strength))


func set_tmp_scene(target_pos : Vector2, target_zoom : float, time_window : float, lerp_speed = 0.6) -> void:
    tmp_zoom = target_zoom
    tmp_pos = target_pos
    tmp_window = time_window
    tmp_lerp_speed = lerp_speed
    tmp_elapsed = 0


func handle_shake(_delta: float) -> void:
    if curr_shake_strength > 0:
        curr_shake_strength = lerpf(curr_shake_strength, 0, shake_fade * _delta)
        offset = random_offset()


func _process(_delta: float) -> void:
    if tmp_elapsed < tmp_window: # Currently in temporary scene such as collision
        tmp_elapsed += _delta
        zoom.x = lerp(zoom.x, tmp_zoom, tmp_lerp_speed)
        zoom.y = lerp(zoom.y, tmp_zoom, tmp_lerp_speed)
        position = lerp(position, tmp_pos, tmp_lerp_speed)
    else: # Basic behaviour
        var target_zoom = zoom_k / (log(%SnakeManager.body.size() + 4) / log(10))
        set_both_zoom(lerp(zoom.x, target_zoom, 0.005))
        var snake_head_pos = %SnakeLayer.map_to_local(%SnakeManager.body[0])
        var anchor = %SnakeLayer.map_to_local(%SnakeManager.body[0] + Direction.dir_to_vec(%SnakeManager.curr_dir)) # One tile after head
        var dir_scaled = anchor - snake_head_pos # Vector of norm 1 in the right direction (conversion from tiles to local coordinates)

        var head_offset = (dir_scaled * %SnakeManager.clock) / 16 # where is the head inside its tile, prevents jittering
        var ideal_pos =  %SnakeLayer.map_to_local(%SnakeManager.body[0] + (advance * %SnakeManager.target_speed) * Direction.dir_to_vec(%SnakeManager.curr_dir)) + head_offset

        position_smoothing_speed = %SnakeManager.target_speed
        position = lerp(position, ideal_pos, 0.001 * speed_factor * %SnakeManager.target_speed)
    handle_shake(_delta)