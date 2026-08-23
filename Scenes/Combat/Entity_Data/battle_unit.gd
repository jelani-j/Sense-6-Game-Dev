class_name BattleUnit
extends Node2D

signal unit_clicked(unit)

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Sprite2D/Area2D

var unit_data: Resource
var current_hp: int
var current_meter: int
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
	if monster_flag != true:
		current_meter = unit_data.meter
	temp_defense = 0
	sprite.texture = unit_data.texture
	sprite.scale = Vector2(2, 2)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("unit_clicked", self)

func take_damage(phase_data):
	var actor = phase_data["actor"]
	var target = phase_data["target"]
	var damage = phase_data["damage"]
	if target.current_hp <= 0:
		die()
		print("death has been reached")
	if target.status_effects.has("status"):
		for effect in target.status_effects:
			if effect["status"] == 1:
				target.current_hp -= roundi(damage * 0.3)
	else:
		target.current_hp -= damage
		if actor.current_meter >= 10:
			print("Flow bar has now been unlocked!")
		else:
			actor.current_meter += damage
			target.current_meter += damage

	
func inventory_use(phase_data):
	var target = phase_data["actor"]
	var item = phase_data["item"]
	var bag = phase_data["Inventory"]
	bag.use_item(item, target)
	
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

# fix this so only the target is affected rather than all units 
func add_status(status_details: Dictionary):
	var target = status_details["target"]
	var status = status_details["status"]
	var duration = status_details["duration"]
	if status_effects == []:
		status_effects.append(status_details)
	for effect in status_effects:
		if effect.has("status") and effect["status"] == status:
			effect.duration += 1

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
