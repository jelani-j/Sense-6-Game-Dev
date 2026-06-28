extends Control

@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"UIContainer/ActionContainer/Party-Members"
@onready var panel_container = $UIContainer/ActionContainer/ActionOptions
@onready var log_container = $UIContainer/ActionContainer/BattleLog
@onready var minigame_container = $"UIContainer/ActionContainer/Mini-Game"
var inventory = Global.Inventory
var member_uis = []
var selected_member = null
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
		party_container.add_child(member_ui)
		member_ui.setup(player)
		member_ui.selected.connect(_on_member_selected)
		member_uis.append(member_ui)
		member_ui.action_selected.connect(_on_action_selected)

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


## Creation + Handling Attack Buttons
func create_attack_buttons(unit: BattleUnit):
	clear_panel()
	var weapon_art_btn = Button.new()
	var martial_art_btn = Button.new()
	weapon_art_btn.text = "Weapon Arts"
	martial_art_btn.text = "Martial Arts"
	martial_art_btn.pressed.connect(create_martial_attack_buttons.bind(unit))
	weapon_art_btn.pressed.connect(create_weapon_attack_buttons.bind(unit))
	panel_container.add_child(weapon_art_btn)
	panel_container.add_child(martial_art_btn)

func create_weapon_attack_buttons(unit):
	clear_panel()
	for attack in unit.unit_data.attacks:
		if attack.attack_category == "Weapon-art":
			var wep_btn = Button.new()
			wep_btn.text = attack.name
			wep_btn.pressed.connect(_on_attack_selected.bind(unit, attack))
			panel_container.add_child(wep_btn)
			
func create_martial_attack_buttons(unit):
	clear_panel()
	for attack in unit.unit_data.attacks:
		if attack.attack_category == "Martial-Art":
			var mart_btn = Button.new()
			mart_btn.text = attack.name
			mart_btn.pressed.connect(_on_attack_selected.bind(unit, attack))
			panel_container.add_child(mart_btn)
	
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
			panel_container.add_child(monster_target)
			monster_target.pressed.connect(trigger_attack.bind(target, selected_attack))

## Handling Button Inputs & sending them to propper next function
func _on_action_selected(unit, action):
	match action:
		"fight":
			clear_panel()
			create_attack_buttons(unit)
		"defend":
			clear_panel()
			trigger_defense(unit)
		"bag":
			clear_panel()
			show_inventory(inventory, unit)
		"run":
			clear_panel()
			trigger_run(unit)
		#"skill":
			#print(player.member_name, "Activating Special Ability!")

## Processing actions & Sending out action object for Processing
func trigger_attack(target, selected_attack):
	if is_instance_valid(target):
		var target_name = target.unit_data.name
		var attack_name = selected_attack.name
		for party_member in member_uis:
			party_member.set_hp_value()
		log_container.text += "\n" + active_player.unit_data.name  + " Used: " + attack_name + " on " + target_name
		action_object = {
			"type": "attack",
			"actor": active_player,
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
		action_object = {
			"type": "bag",
			"actor": unit,
			"item": slot.item
		}
	current_action.emit(action_object)
	
