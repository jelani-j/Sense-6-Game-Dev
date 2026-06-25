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
#change this to recieve damage (process amount)
func take_damage(attack_data: AttackData, target_data, power):
	var amount = attack_data.damage
	var def = target_data
	if defending == true:
		current_hp -= (amount/2)
	else:
		current_hp -= ((power + amount) - def )
		print(((power + amount) - def ))
	if current_hp <= 0:
		die()

#make this a damage calc function that accepts inputs and does a formula to return amount 
#pass characters data + attack info into a function and process the calc [ power? attack dmage? minigame res>]
#handle critical hits + calc speed into hit chance 
#determine all stat attributes before scaling 
func process_attack(attack_data: AttackData, power, defense, minigame_result):
	var amount = attack_data.damage
	var def = defense
	var accuracy: int
	if minigame_result == "perfect":
		accuracy = 2
	elif minigame_result == "good":
		accuracy = 1
	else:
		minigame_result = ""
		accuracy = 0
	var player_damage_calc = accuracy + ((amount + power) - def)
	current_hp -= player_damage_calc
	if current_hp <= 0:
		die()
	
#make this a function that handles all status damage 
func status_damage(status):
	match status:
		"Poison":
			# tick damage
			current_hp -= 1
		"Fire":
			# refuces power for attacks + tick damage 
			current_hp -= 1
		"Stun":
			# cant act 
			print("User is dazed and cannot attack")
		"Electrified":
			# cant use skills 
			print("use of skills have been disabled temporairly")
		"Bleeding":
			# tick damage + reduces defense
			current_hp -= 1
		"Soul Shatterd":
			# if hit too many times with this sets hp to 1 
			print("the very soul begins to cry out in pain")
	
func add_status(stauts_details: Dictionary):
	for existing_status in status_effects:
		if existing_status["status"] == stauts_details["status"]:
			existing_status["duration"] += stauts_details["duration"]
			return
	status_effects.append(stauts_details)

func get_status():
	return status_effects

func clear_status():
	status_effects.clear()
	
func set_defending(value: bool):
	defending = value

func is_alive():
	return current_hp > 0

func die():
	queue_free()
