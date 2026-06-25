extends VBoxContainer
@onready var results_label = $Panel/VBoxContainer/PanelContainer/Label
@onready var button = $Panel/Button
var player_trat = Global.dominant_trait
var test_trait = "Inquisitive"
var desc_sequence = 0
var trait_descriptions = {
	"Inquisitive": [
		"You love learning, exploring ideas, and asking questions.",
		"A deep passion for questioning the unkown, and discovering something new",
		"be careful with how far you reach, as some knowledge is better left alone..."
	],
	"Anxious": [
		"You tend to anticipate problems and prepare for uncertainty.",
		"Constantly trying to predict for the worst case scenario which helps for dire situations",
		"But also may hinder your enjoyment, you find yourself more afraid of the unkown than others"
	],
	"Passionate": [
		"You feel deeply and throw yourself fully into what matters.",
		"You find ways to pour your very soul into your intrests achieving greatness",
		"But pouting so much of yourself into one craft can often leave other areas lacking"
	],
	"Ambitious": [
		"You’re driven to grow, succeed, and push your limits.",
		"A real go-getter asking someone for something is never too hard of a task",
		"However, sometimes your ambition can cloud your judgement, leaving you to rush into new situations head first"
	],
	"Relaxed": [
		"You stay calm and grounded, even under pressure.",
		"Some may even say a bit too relaxed at times...",
		"being so relaxed makes you more adverse to change, and unlikely to fix old habbits"
	],
	"Neurotic": [
		"You experience emotions intensely and reflect deeply.",
		"Sometimes you may take what people say to heart, and find yourself pondering on past interactions",
		"at times it can be difficult to rest, as your mind never seems to be at ease "
	]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_description(desc_sequence)

func load_description(desc_id: int):
	var results = trait_descriptions[player_trat]
	results_label.text += "\n" +(results[desc_id])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	if desc_sequence >= 2:
		results_label.text = "With that, it is time to begin this journey... good luck."
		button.text = "Begin"
	else:
		desc_sequence +=1
		load_description(desc_sequence)
	
