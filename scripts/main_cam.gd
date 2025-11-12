extends Camera2D

enum STATE {START, FREE, DEBUG}

var curr_state = STATE.START
var lookahead : int = 2

var shake_strength: float = 2.0
var shake_fade: float = 5
var rng = RandomNumberGenerator.new()
var curr_shake_strength: float = 0.0
@onready var starting_pos = position

var zoom_tween: Tween
@onready var initial_zoom = zoom

func start_shake(strength = 2.0, fade = 5.0) -> void:
	curr_shake_strength = strength
	shake_fade = fade

func get_target_pos():
	var snake_head_pos = %SnakeLayer.map_to_local(%SnakeManager.body[0])
	var anchor = %SnakeLayer.map_to_local(%SnakeManager.body[0] + Direction.dir_to_vec(%SnakeManager.curr_dir)) # One tile after head
	var dir_scaled = anchor - snake_head_pos # Vector of norm 1 in the right direction (conversion from tiles to local coordinates)

	var head_offset = (dir_scaled * %SnakeManager.clock) / 16 # where is the head inside its tile, prevents jittering
	var exact_head_pos =  %SnakeLayer.map_to_local(%SnakeManager.body[0]) + head_offset
	var diff_vector = exact_head_pos - starting_pos
	return starting_pos + diff_vector * max(0, diff_vector.length() - 10)* .001

func on_collision():
	var snake_head_pos = %SnakeLayer.map_to_local(%SnakeManager.body[0])
	var anchor = %SnakeLayer.map_to_local(%SnakeManager.body[0] + Direction.dir_to_vec(%SnakeManager.curr_dir)) # One tile after head
	var dir_scaled = anchor - snake_head_pos # Vector of norm 1 in the right direction (conversion from tiles to local coordinates)

	var head_offset = (dir_scaled * %SnakeManager.clock) / 16 # where is the head inside its tile, prevents jittering
	var exact_head_pos =  %SnakeLayer.map_to_local(%SnakeManager.body[0]) + head_offset + dir_scaled * 3
	
	zoom_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(self, "zoom", Vector2(2.5,2.5), .2)
	zoom_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	zoom_tween.tween_property(self, "zoom", initial_zoom, 3.)
	

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-curr_shake_strength, curr_shake_strength), rng.randf_range(-curr_shake_strength, curr_shake_strength))


func handle_shake(delta: float) -> void:
	if curr_shake_strength > 0:
		curr_shake_strength = lerpf(curr_shake_strength, 0, shake_fade * delta)
		offset = random_offset()

func any_tween_active():
	return [zoom_tween].any(func(t:Tween): return t and t.is_running())

func _process(delta: float) -> void:
	handle_shake(delta)
	match curr_state:
		STATE.START:
			position = lerp(position, get_target_pos(), .1)


func _ready() -> void:
	Signals.on_collision.connect(on_collision)
	
