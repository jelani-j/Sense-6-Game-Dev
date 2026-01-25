extends VBoxContainer
#loads the prompt and answer variables 
@onready var intro_label = $Intro_Prompt/Intro_Prompt
@onready var buttons = $Next_Button/Continue

#sets currentquestion to 1 for now
var current_intro_id = 0

var intro_scene = {
	0: {
		"prompt": "You are fragmented, and lost....",
		"response": ". . ."
	},
	1: {
		"prompt": "the only one who can put you back together is yourself.", 
		"response": "..?"
	},
	2: {
		"prompt": "You're going to answer a series of questions soon, awnser honestly.",
		"response": "wait-"
	}
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_intro(current_intro_id)

func load_intro(intro_id: int):
	var intro_text = intro_scene[intro_id]
	#grabs the "question" attribute from the dict
	intro_label.text = intro_text["prompt"]
	buttons.text = intro_text["response"]

func _on_continue_pressed() -> void:
	if current_intro_id < 3:
		print(current_intro_id)
		load_intro(current_intro_id)
		current_intro_id += 1
	else:
		get_tree().change_scene_to_file("res://Scenes/Quiz-Components/personality_quiz.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
