extends Node

func loop():
	$Bass.play()
	$Drums.play()


func _ready():
	loop()
	Signals.map_updated.connect(start_drums)
	SnakeProps.MusicPlayer = self

func _on_drums_finished() -> void:
	#await get_tree().create_timer().timeout
	loop()

func start_drums():
	get_tree().create_tween().tween_property($Drums, "volume_db", 0.0, .5)
	Signals.map_updated.disconnect(start_drums)
	
func setup_end():
	get_tree().create_tween().tween_property($Drums, "volume_db", -80.0, 2.)
	get_tree().create_tween().tween_property($Bass, "pitch_scale", .85, 50.)
	

func final_stop():
	get_tree().create_tween().tween_property($Bass, "volume_db", -80.0, 5.)
	
