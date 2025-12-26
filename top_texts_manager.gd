extends Node

var level = 0
@export var credits_canvas_bg: ColorRect

var last_sequence_flag = false
var first_sentences = [
	"Wow... what is going on...",
	"Holy shit what is hapening ??!"
]

var second_sentences = [
	"Maybe I could get out... ?",
	"Hmm.. These caves keep on extending..",
	"Again ??"
]

var third_sentences = [
	"The exit should not be too far now..",
	"I'm almost out I can feel it"
]

var fourth_sentences = [
	"I can feel fresh air !",
	"I heard an exit open !!",
	"Holy shit there is a way out !"
]

var final_string = [
	"I knew I could get out !!!",
	"It feels so good to finally be free...",
	"I can go wherever I want, whenever I want",
	"At least I'm sure I wont bump into walls now !",
	"a-and I can grow as big as I want",
	"I don't even need to grab these juice anymore", 
	"and I dont even need to grab these apples anymore...",
	"I don't even...",
	"I don't even need to grow anymore...", 
	"...", 
	"why did I even do all that..",
	"w-what do I do now.. ?",
	"w-wait..",
	"DONT LEAVE ME"
]

var all_sentences = [
	first_sentences,
	second_sentences,
	third_sentences,
	fourth_sentences
]

func sleep(time):
	await get_tree().create_timer(time).timeout

func start_bg_credits():
	credits_canvas_bg.visible = true
	credits_canvas_bg.modulate.a = 0.
	create_tween().tween_property(credits_canvas_bg, "modulate:a", 1., 20.)
	
func final_goodbye():
	SnakeProps.Audio.deafen_glass_break()
	
	var base_wait = 7.
	
	TopText.instantiate("I knew I could get out !!!")
	await sleep(base_wait)
	
	TopText.instantiate("There is so much space out there :3")
	await sleep(base_wait)
	
	TopText.instantiate("It feels so good to finally be free...")
	await sleep(base_wait)
	
	TopText.instantiate("I can go wherever I want, whenever I want")
	await sleep(base_wait)
	
	TopText.instantiate("At least I'm sure I wont bump into walls now !")
	await sleep(base_wait + 2.)
	
	TopText.instantiate("a-and I can grow as big as I want")
	await sleep(base_wait)
	
	TopText.instantiate("I don't even need to grab these juice anymore")
	await sleep(base_wait)
	
	TopText.instantiate("and I dont even need to grab these apples anymore...")
	await sleep(base_wait - 1.)
	
	TopText.instantiate("I don't even...", 0.)
	await sleep(base_wait - 2.)
	
	TopText.instantiate("I don't even need to grow anymore...")
	await sleep(base_wait)
	
	start_bg_credits()
	
	TopText.instantiate("I don't even know what to do now... ?")
	await sleep(base_wait - 1.)
	
	TopText.instantiate("")
	TopText.instantiate("w-what do i do now ?")
	await sleep(base_wait - 1.)
	
	TopText.instantiate("w-wait..")
	await sleep(base_wait - 2.)
	
	TopText.instantiate("")
	TopText.instantiate("DONT LEAVE ME")
	await sleep(base_wait)
	
	await get_tree().create_timer(2.).timeout
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func try_final_sequence():
	var head_pos: Vector2i = SnakeProps.SM.body[0]
	if !last_sequence_flag and (abs(head_pos.x) > 190 or abs(head_pos.y) > 190):
		last_sequence_flag = true
		final_goodbye()

func update():
	#final_goodbye()
	if level >= len(all_sentences):
		print("too many level ups")
		return
	var curr: Array = all_sentences[level]
	level += 1
	var text = curr.pick_random()
	TopText.instantiate(text)

func _ready() -> void:
	Signals.map_updated.connect(update)
	Signals.on_step.connect(try_final_sequence)
