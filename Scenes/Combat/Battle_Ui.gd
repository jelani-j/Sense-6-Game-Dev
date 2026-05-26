extends Control

@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"ActionContainer/Party-Members"
@onready var panel_container = $ActionContainer/ActionOptions
@onready var log_container = $ActionContainer/BattleLog
var inventory = Global.Inventory
var member_uis = []
enum BattleState {
	IDLE,
	SELECTING_CHARACTER,
	SELECTING_ACTION,
	TARGETING,
	EXECUTING,
	BLOCKING,
	RUNNING,
	UTILITY,
	SPECIAL,
	VICTORY,
	DEFEAT,
	ESCAPED
}
signal battle_end_condition(state)
var battle_state := BattleState.IDLE
var selected_member = null
var players_array: Array[BattleUnit] = []
var enemies_array: Array[BattleUnit] = []
var active_player : BattleUnit
var selected_attack : AttackData
var action_queue = []
var action_obejct: Dictionary = {
		"type": "",
		"actor": BattleUnit,
		"target": BattleUnit,
	}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
# Called when the node enters the scene tree for the first time.
func start_battle(player_data: Array[PlayerData], monser_data: Array[MonsterData]):
	spawn_monster(monser_data)
	spawn_player(player_data)
	spawn_party_member_UI(players_array)

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

func spawn_party_member_UI(players_array):
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
	
## UI Option Functionality ##
func clear_panel():
	for child in panel_container.get_children():
		child.queue_free()

func create_attack_buttons(unit: BattleUnit):
	clear_panel()
	battle_state = BattleState.SELECTING_ACTION
	var weapon_art_btn = Button.new()
	var martial_art_btn = Button.new()
	weapon_art_btn.text = "Weapon Arts"
	martial_art_btn.text = "Martial Arts"
	martial_art_btn.pressed.connect(create_martial_attack_buttons.bind(unit))
	weapon_art_btn.pressed.connect(create_weapon_attack_buttons.bind(unit))
	panel_container.add_child(weapon_art_btn)
	panel_container.add_child(martial_art_btn)
	#for attack in unit.unit_data.attacks:
		#var btn = Button.new()
		#btn.text = attack.name
		#btn.pressed.connect(_on_attack_selected.bind(unit, attack))
		#panel_container.add_child(btn)

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
	
#
func _on_attack_selected(player: BattleUnit, attack: AttackData):
	battle_state = BattleState.TARGETING
	active_player = player
	selected_attack = attack
	clear_panel()
	show_targets(enemies_array)
## Attack Ui Option Functionality ##
func attack_target(target: BattleUnit, attack: AttackData):
	battle_state = BattleState.EXECUTING
	clear_panel()
	action_obejct = {
		"type": "attack",
		"actor": active_player,
		"target": target,
		"attack": selected_attack
	}
	action_queue.push_back(action_obejct)
	resolve_turns()
func check_battle_end(active_player: BattleUnit):
	var living_enemy = 0
	var living_player = 0
	for enemy in enemies_array:
		if is_instance_valid(enemy) and enemy.current_hp > 0:
			living_enemy += 1
	for player in players_array:
		if is_instance_valid(player) and player.current_hp > 0:
			living_player += 1
	if living_enemy == 0:
		print("enemies all dead ")
		despawn_member_ui(active_player)
		battle_state = BattleState.VICTORY
		log_container.text += "\n" + "Victory!"
		return true
	if living_player == 0:
		despawn_member_ui(active_player)
		battle_state = BattleState.DEFEAT
		log_container.text += "\n" + "All Allies Slain..."
		return true
			
func handle_attack(text_display_actor, target_data, attack_data, actor_data):
	if is_instance_valid(target_data):
		var target_name = target_data.unit_data.name
		var attack_name = attack_data.name
		var power = actor_data.attack
		target_data.take_damage(attack_data, target_data.unit_data.defense, power)
		for party_member in member_uis:
			party_member.set_hp_value()
		log_container.text += "\n" + text_display_actor + " Used: " + attack_name + " on " + target_name
		if target_data.current_hp <= 0:
			log_container.text += "\n" + target_name + " was Slain"
			return true
		

func handle_defense(text_display_actor, actor):
	battle_state = BattleState.BLOCKING
	actor.set_defending(true)
	log_container.text += "\n" + text_display_actor + " is Defending"

func handle_run(text_display_actor):
	battle_state = BattleState.RUNNING
	log_container.text += "\n" + text_display_actor + " is Running away!"

func _on_action_selected(unit, action):
	if battle_state != BattleState.VICTORY or BattleState.DEFEAT:
		match action:
			"fight":
				create_attack_buttons(unit)
			"defend":
				clear_panel()
				action_obejct = {
					"type": "defend",
					"actor": unit
				}
				action_queue.push_back(action_obejct)
				resolve_turns()
			"bag":
				clear_panel()
				show_inventory(inventory, unit)
				battle_state = BattleState.UTILITY
			"run":
				clear_panel()
				action_obejct = {
					"type": "run",
					"actor": unit
				}
				action_queue.push_back(action_obejct)
				resolve_turns()
			#"skill":
				#battle_state = BattleState.SPECIAL
				#print(player.member_name, "Activating Special Ability!")
	else:
		resolve_turns()
## Displaying UI Options ##
func _on_member_selected(member):
	if battle_state != BattleState.IDLE:
		return
	battle_state = BattleState.SELECTING_CHARACTER
	print("Selecting:", member.member_name)
	
func show_targets(targets: Array[BattleUnit]):
	for target in targets:
		if is_instance_valid(target):
			var monster_target = Button.new()
			monster_target.text = target.unit_data.name
			panel_container.add_child(monster_target)
			monster_target.pressed.connect(attack_target.bind(target, selected_attack))
		else:
			battle_state = BattleState.VICTORY
func show_inventory(bag: InventoryData, unit):
	for slot in bag.slots:
		var slot_button = Button.new()
		slot_button.text = slot.item.name + " x" + str(slot.quantity)
		panel_container.add_child(slot_button)
		slot_button.pressed.connect(inventory_use.bind(slot.item, bag, unit))
		
func inventory_use(item: ItemData, bag: InventoryData, unit: BattleUnit):
	action_obejct = {
		"type": "bag",
		"actor": unit,
		"item": item,
		"bag": bag
	}
	
	action_queue.push_back(action_obejct)
	clear_panel()
	resolve_turns()
## Monster AI Functionality ##
func monster_ai(enemies_array, players_array):
	for monster in enemies_array:
		if is_instance_valid(monster):
			action_obejct = {
				"type": "attack",
				"actor": monster,
				"target": players_array[0],
				"attack": monster.unit_data.attacks[0]
			}
			action_queue.push_back(action_obejct)
## Turn Processing ##
func execute_actions(action_queue):
	for action in action_queue:
		if is_instance_valid(action["actor"]):
			var text_display_actor = action["actor"].unit_data.name
			var actor_data = action["actor"].unit_data
			match action["type"]:
				"attack":
					handle_attack(text_display_actor, action["target"], action["attack"], actor_data)
					if check_battle_end(action["actor"]) == true:
						battle_end_condition.emit(battle_state)
						break
				"defend":
					handle_defense(text_display_actor, action["actor"])
				"bag":
					var item = action["item"]
					var bag = action["bag"]
					var actor = action["actor"]
					log_container.text += "\n" + text_display_actor + " is Using: " + item.name
					bag.use_item(item, actor)
					
				"run":
					handle_run(text_display_actor)
					battle_state = BattleState.ESCAPED
					battle_end_condition.emit(battle_state)
					despawn_member_ui(action["actor"])

func resolve_turns():
	monster_ai(enemies_array, players_array)
	execute_actions(action_queue)
	for unit in action_queue:
		unit["actor"].set_defending(false)
		action_queue.clear()
