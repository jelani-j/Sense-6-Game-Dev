extends Button
var character_name : String
var icon_texture : Texture2D

var max_hp: BattleUnit
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
@onready var name_title = $HBoxContainer/Status/Name
var base_position : Vector2
var tween : Tween
var is_selected:= false
signal selected(member)
signal action_selected(unit, action)
var unit: BattleUnit
var member_name


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	extra_stats.visible = false
	base_position = position
	#icon_symbol.texture = preload("res://icon.svg")

	#hp_bar.max_value = max_hp
	#hp_bar.value = hp
##
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
	if not is_selected:
		animate_to(base_position.y - 20)

func _on_mouse_exited() -> void:
	if not is_selected:
		animate_to(base_position.y)
	#extra_stats.visible = false

func set_hp_value():
	hp_bar.value = unit.current_hp

func setup(unit_data: BattleUnit):
	self.unit = unit_data
	member_name = unit.unit_data.name
	hp_bar.max_value = int(unit.unit_data.max_hp)
	print(hp_bar.max_value)
	name_title.text = member_name
	
	# set portrait, hp bar, etc
	
func _on_pressed() -> void:
	is_selected = true
	emit_signal("selected", self)
	animate_to(base_position.y - 20)
	extra_stats.visible = true
	
	
func _on_fight_btn_pressed() -> void:
	action_selected.emit(unit, "fight")

func _on_def_btn_pressed() -> void:
	action_selected.emit(unit, "defend")

func _on_skill_btn_pressed() -> void:
	action_selected.emit(unit, "skill")

func _on_bag_btn_pressed() -> void:
	action_selected.emit(unit, "bag")

func _on_run_btn_pressed() -> void:
	action_selected.emit(unit, "run")
