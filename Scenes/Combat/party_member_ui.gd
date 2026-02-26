extends Button
var character_name : String
var icon_texture : Texture2D

var max_hp = 100.0
var hp  = 100

var max_stam  = 50.0
var stam  = 50

var max_flow = 30.0
var flow = 30

@onready var name_label = $HBoxContainer/Status/Name
@onready var hp_bar = $HBoxContainer/Status/HPBar
#@onready var stam_bar = $HBoxContainer/Status/StamBar
#@onready var flow_bar = $HBoxContainer/Status/FlowBar
@onready var icon_symbol = $HBoxContainer/Icon
@onready var extra_stats = $HBoxContainer/Status/Extra_Stats
var base_position : Vector2
var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	extra_stats.visible = false
	base_position = position
	name_label.text = 'Test-Character'
	icon_symbol.texture = preload("res://icon.svg")

	hp_bar.max_value = max_hp
	hp_bar.value = hp
#
	#stam_bar.max_value = max_stam
	#stam_bar.value = stam
#
	#flow_bar.max_value = max_flow
	#flow_bar.value = flow


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func animate_to(target_y: float):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:y", target_y, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	animate_to(base_position.y - 20)
	#tween.tween_property(self, "position:y", position.y - 20, 0.3).set_trans(Tween.TRANS_QUAD)\
	#.set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	animate_to(base_position.y)
	#tween.tween_property(self, "position:y", position.y + 20, 0.3).set_trans(Tween.TRANS_QUAD)\
	#.set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	extra_stats.visible = true
