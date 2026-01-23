extends VBoxContainer

#loads the prompt and answer variables 
@onready var question_label = $Question/Prompt
@onready var buttons = [$Awnsers/Option1, $Awnsers/Option2, $Awnsers/Option3] 

#sets currentquestion to 1 for now
var current_question_id = 0
# traits dict to increase based on options
var traits = {
	"Inquisitive": 0,
	"Anxious": 0,
	"Nuerotic": 0,
	"Passionate": 0,
	"Ambitious": 0,
	"Relaxed": 0,
	"Null": 0
}

# dictionary of question and options
#each question will have 3 options as answer choices
#each option matches to the corresponding trait in order.

var personality_questions = {
	0: {
		"question": "You are fragmented, and lost.... 
		the only one who can put you back together is yourself. 
		You're going to answer a series of questions soon, awnser honestly.",
		"options": ["What?","I don't want to","okay"],
		"traits": ["Null","Null","Null"]
	},
	1:{
		"question": "When starting something new what's your first instinct?",
		"options": ["Research the task until you discover a way to do it", "Worry about what could go wrong", "Jump into the challenge" ],
		"traits": ["Inquisitive", "Anxious", "Ambitious"]
	},
	2:{
		"question": "You were introducing yourself to someone new when suddenly you stutterd mid sentance, what thoughts come to mind?",
		"options": ["whatever, everyone makes mistakes", "pretend it didn't happen and push forward", "I feel so stupid!"],
		"traits": ["Relaxed","Nuerotic","Ambitious"],
	},
	3:{
		"question": "What kind of story genre do you like most?",
		"options": ["Mystery","Drama","Comedy"],
		"traits": ["Inquisitive", "Ambitious", "Relaxed"],
	},
	4:{
		"question": "You just failed a test after studying for hours, what do you do?",
		"options": [
			"review the test to see where you went wrong",
			"get angry that you lost even after practicing",
			"use the failure as fuel to do better on the next one"],
		"traits": ["Inquisitive", "Nuerotic", "Passionate"],
	},
	5:{
		"question": "How do you usually feel before a big decision?",
		"options": [
			"Excited and emotionally invested in the outcome",
			"Stressed about all the possible ways it could go wrong",
			"Overwhelmed and stuck replaying every possibility"],
		"traits": ["Passionate","Anxious","Nuerotic"],
	},
	6:{
		"question": "What best describes your ideal work style?",
		"options": [
			"I put my heart into what I do and care deeply about results",
			"I set big goals and push myself to reach them",
			"I prefer a steady pace with minimal pressure"
		],
		"traits": ["Passionate","Ambitious","Relaxed"],
	},
	7:{
		"question": "When facing uncertainty, how do you react?",
		"options": [
			"I worry about what might happen and prepare for the worst",
			"I lean into my feelings and let them guide my response",
			"I stay calm and take things as they come"
		],
		"traits": ["Anxious","Passionate","Relaxed"],
	},
	8:{
		"question": "What do you think about when you're all alone?",
		"options": [
			"My mind races with worries or future concerns",
			"I enjoy the calm and use it to recharge",
			"I overthink past mistakes or small details"],
		"traits": ["Anxious","Relaxed","Nuerotic"],
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_question(current_question_id)

func load_question(question_id: int):
	var question = personality_questions[question_id]
	#grabs the "question" attribute from the dict
	question_label.text = question["question"]
	# set the button attributes
	for i in range(buttons.size()):
		buttons[i].text = question["options"][i]

func _on_option_pressed() -> void:
	var pressed_button = get_viewport().gui_get_focus_owner()
	var option_index = buttons.find(pressed_button)
	if option_index == -1:
		return
	apply_answer(option_index)
	if current_question_id != 7:
		current_question_id += 1
		load_question(current_question_id)
	
func apply_answer(option_index: int):
	var question = personality_questions[current_question_id]
	var traitz = question["traits"][option_index]
	traits[traitz] += 1
	print("Added 1 point to:", traitz)
	print("currently on question:", current_question_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
