extends VBoxContainer

# traits dict to increase based on options
var traits = {
	"Inquisitive": 0,
	"Anxious": 0,
	"Nuerotic": 0,
	"Passionate": 0,
	"Ambitious": 0,
	"Relaxed": 0
}

# dictionary of question and options
var personality_questions = {
	"q1":{
		"question": "When starting something new what's your first instinct?",
		#each option gives a value point in a personality area 
		"options": ["Research the task until you discover a way to do it", "Worry about what could go wrong", "Jump into the challenge" ],
		"results": [traits["Inquisitive"]+1, traits["Anxious"]+, traits["Ambitious"]+1 ]
		
	},
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
