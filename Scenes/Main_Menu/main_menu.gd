extends Control
#Sets button and label variables from main menu to be edited
@onready var menu_label = $PanelContainer/Label
@onready var menu_buttons = [$VBoxContainer/Options_Button, $VBoxContainer/New_Game_Button, $VBoxContainer/Other_Button]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Button press mechanisms
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Quiz-Components/Front-Screen.tscn")

func _on_options_button_pressed() -> void:
	pass # Replace with function body.

func _on_other_button_pressed() -> void:
	pass # Replace with function body.

#Button Hover mechanisms
func _on_new_game_button_mouse_entered() -> void:
	menu_label.text = "Start a new Game"
	
func _on_other_button_mouse_entered() -> void:
	menu_label.text = "Select to see available special episodes"

func _on_options_button_mouse_entered() -> void:
	menu_label.text = "Select to see options such as game text, speed, and view controls"
