extends Control

#containers for preparing nodes to be populated
@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"UIContainer/ActionContainer/Party-Members"
@onready var panel_container = $"UIContainer/ActionContainer/ActionOptions"
@onready var log_container = $"UIContainer/ActionContainer/BattleLog"
@onready var minigame_container = $"UIContainer/ActionContainer/Mini-Game"
@onready var containers = party_container.get_children()
@onready var action_options = $"UIContainer/ActionContainer/ActionOptions"
@onready var menu_options = $"UIContainer/ActionContainer/ActionOptions/Menu"
@onready var move_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/MoveSelection"
@onready var inventory_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/InventorySelection"
@onready var attack_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/AttackSelection"
@onready var target_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/TargetSelection"
@onready var active_player_border = $"UIContainer/ActionContainer/ActionOptions/Active_Player_Border"
@onready var active_player_slot = $"UIContainer/ActionContainer/ActionOptions/Active_Player_Border/selected_player"
var inventory = Global.Inventory
var member_uis = []

var selected_member = null
var unit = BattleUnit.new()
var players_array: Array[BattleUnit] = []
var enemies_array: Array[BattleUnit] = []
var active_player : BattleUnit
var selected_attack : AttackData
var action_queue = []
var action_object: Dictionary = {}
signal battle_end_condition(state)
signal current_action(action_object)
var battle_controller = BattleController.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	battle_controller._current_action_listener(self)
	battle_controller.battle_queue_ready.connect(execute_phases)

# Called when the node enters the scene tree for the first time.
func start_battle(player_data: Array[PlayerData], monser_data: Array[MonsterData]):
	spawn_monster(monser_data)
	spawn_player(player_data)
	spawn_party_member_UI()

## Spawning Entities ##
func spawn_monster(monster_data: Array[MonsterData]):
	for i in range(monster_data.size()):
		var unit = load("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$EnemyContainer.add_child(unit)
		unit.setup(monster_data[i], true)
		unit.global_position = enemy_slots[i].global_position
		enemies_array.append(unit)

func spawn_player(player_data: Array[PlayerData]):
	for i in player_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$PlayerContainer.add_child(unit)
		unit.setup(player_data[i], false)
		unit.global_position = player_slots[i].global_position
		players_array.append(unit)

func spawn_party_member_UI():
	for player in players_array:
		var member_ui = preload("res://Scenes/Combat/PartyMemberUI.tscn").instantiate()
		for container in containers:
			if member_ui.get_parent() != null:
				continue
			else:
				container.add_child(member_ui)
		member_ui.setup(player)
		member_ui.selected.connect(_on_member_selected)
		member_uis.append(member_ui)
		#member_ui.action_selected.connect(_on_action_selected)

## Despawn Entities ##
func despawn_member_ui(party_member: BattleUnit):
	for member in member_uis:
		if party_member.unit_data.name == member.member_name:
			party_container.remove_child(member)

func despawn_entity():
	for enemy in enemies_array:
		if enemy.current_hp <= 0:
			enemy.die()

## UI Option Functionality ##
func clear_panel():
	for child in panel_container.get_children():
		child.queue_free()

func _on_member_selected(member):
	print("Selecting:", member.member_name)
	party_container.hide()
	var active_member_ui = member.duplicate()
	active_player_slot.add_child(active_member_ui)
	#hide these after end of player phase
	action_options.show()
	menu_options.show()
	active_player_border.show()
	move_selection.show()
	for player in players_array:
		if player.unit_data.name == member.member_name:
			active_player = player
		else:
			print("error occured and counlt match the player data")
			continue


## Creation + Handling Attack Buttons
func create_attack_buttons(unit: BattleUnit):
	var weapon_art_btn = Button.new()
	var martial_art_btn = Button.new()
	weapon_art_btn.text = "Weapon Arts"
	martial_art_btn.text = "Martial Arts"
	martial_art_btn.pressed.connect(create_martial_attack_buttons.bind(unit))
	weapon_art_btn.pressed.connect(create_weapon_attack_buttons.bind(unit))
	attack_selection.add_child(weapon_art_btn)
	attack_selection.add_child(martial_art_btn)

func create_weapon_attack_buttons(unit):
	for attack in unit.unit_data.attacks:
		if attack.attack_category == "Weapon-art":
			var wep_btn = Button.new()
			wep_btn.text = attack.name
			wep_btn.pressed.connect(_on_attack_selected.bind(unit, attack))
			attack_selection.add_child(wep_btn)
			
func create_martial_attack_buttons(unit):
	clear_panel()
	for attack in unit.unit_data.attacks:
		if attack.attack_category == "Martial-Art":
			var mart_btn = Button.new()
			mart_btn.text = attack.name
			mart_btn.pressed.connect(_on_attack_selected.bind(unit, attack))
			attack_selection.add_child(mart_btn)
	
func _on_attack_selected(player: BattleUnit, attack: AttackData):
	active_player = player
	selected_attack = attack
	clear_panel()
	show_targets(enemies_array)
	

func show_targets(targets: Array[BattleUnit]):
	for target in targets:
		if is_instance_valid(target):
			var monster_target = Button.new()
			monster_target.text = target.unit_data.name
			target_selection.add_child(monster_target)
			monster_target.pressed.connect(trigger_attack.bind(target, selected_attack))

#minigame visuals
func spawn_minigame():
	print("make logic for modular minigame spawning here similar to signal listener enum val")


## Processing actions & Sending out action object for Processing
func trigger_attack(target, selected_attack):
	if is_instance_valid(target):
		var target_name = target.unit_data.name
		var attack_name = selected_attack.name
		log_container.text += "\n" + active_player.unit_data.name  + " Used: " + attack_name + " on " + target_name
		action_object = {
			"type": "attack",
			"actor": active_player,
			"move": selected_attack,
			"target": target
		}
		current_action.emit(action_object)

func trigger_defense(actor):
	log_container.text += "\n" + actor.unit_data.name + " is Defending"
	action_object = {
		"type": "defend",
		"actor": actor
	}
	current_action.emit(action_object)

func trigger_run(actor):
	log_container.text += "\n" + actor.unit_data.name + " is Running away!"
	action_object = {
		"type": "run",
		"actor": actor
	}
	current_action.emit(action_object)

func show_inventory(bag: InventoryData, unit):
	for slot in bag.slots:
		var slot_button = Button.new()
		slot_button.text = slot.item.name + " x" + str(slot.quantity)
		panel_container.add_child(slot_button)
		slot_button.pressed.connect(send_inventory_data.bind(slot.item, bag, unit))
		
func send_inventory_data(item, bag, unit):
	action_object = {
			"type": "bag",
			"Inventory": bag,
			"actor": unit,
			"item": item
		}
	current_action.emit(action_object)

func death_check():
	for unit in players_array:
		if unit.current_hp <= 0:
			unit.die()
			party_container.remove_child(unit)
	for unit in enemies_array:
		if unit.current_hp <= 0:
			unit.die()

#Turn Processing
func execute_phases(queue):
	for phases in queue:
		match phases["type"]:
			"status":
				var target = phases["target"]
				if target.is_alive():
					target.add_status(phases)
				death_check()
			# next work on minigame for attack data [ only for skills, attk will be normal but build mtr]
			"attack":
				var target = phases["target"]
				if target.is_alive():
					target.take_damage(phases)
					for party_member in member_uis:
						party_member.set_hp_value()
				death_check()
			# for bag add if clause for if no items in inventory bag should not count as action
			"bag":
				var actor = phases["actor"]
				if actor.is_alive():
					actor.inventory_use(phases)
					for party_member in member_uis:
						party_member.set_hp_value()
				clear_panel()

#Button press triggers 
func _on_fight_pressed() -> void:
	move_selection.hide()
	attack_selection.show()
	create_attack_buttons(active_player)

func _on_def_pressed() -> void:
	move_selection.hide()
	trigger_defense(active_player)

func _on_run_pressed() -> void:
	move_selection.hide()
	trigger_run(active_player)

func _on_bag_pressed() -> void:
	move_selection.hide()
	inventory_selection.show()
	show_inventory(inventory, active_player)

func _on_skill_pressed() -> void:
	pass # Replace with function body.[ implement meter and bar here with minigames ]

func _on_flow_pressed() -> void:
	pass # Replace with function body. [ implement flow state after multiple good scored skills]
