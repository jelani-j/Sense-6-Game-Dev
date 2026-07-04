class_name BattleUnit
extends Node2D

signal unit_clicked(unit)

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Sprite2D/Area2D

var unit_data: Resource
var current_hp: int
var is_enemy: bool 
var status_effects: Array = []
@export var defending = false
@export var temp_defense: int 
#temp stats

func _ready():
	area.input_event.connect(_on_input_event)

func setup(data: Resource, monster_flag: bool):
	is_enemy = monster_flag
	unit_data = data
	current_hp = unit_data.max_hp
	temp_defense = 0
	sprite.texture = unit_data.texture
	sprite.scale = Vector2(2, 2)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("unit_clicked", self)

func take_damage(amount):
	current_hp -= amount
	if current_hp <= 0:
		die()	
	
#make this a function that handles all status damage 
#func set_status(status):
	#match status:
		#"Poison":
			## tick damage
			#current_hp -= 1
		#"Fire":
			## refuces power for attacks + tick damage 
			#current_hp -= 1
		#"Stun":
			## cant act 
			#print("User is dazed and cannot attack")
		#"Electrified":
			## cant use skills 
			#print("use of skills have been disabled temporairly")
		#"Bleeding":
			## tick damage + reduces defense
			#current_hp -= 1
		#"Soul Shatterd":
			## if hit too many times with this sets hp to 1 
			#print("the very soul begins to cry out in pain")
	
func add_status(stauts_details: Dictionary):
	for existing_status in status_effects:
		if existing_status["status"] == stauts_details["status"]:
			existing_status["duration"] += stauts_details["duration"]
			return
	status_effects.append(stauts_details)

func status_tick_down():
	for existing_status in status_effects:
		existing_status["duration"] -= 1
		if existing_status["duration"] == 0:
			clear_status(existing_status["status"])
			
func get_status():
	return status_effects

func clear_status(status):
	status_effects.erase(status)
	

func is_alive():
	return current_hp > 0

func die():
	queue_free()
