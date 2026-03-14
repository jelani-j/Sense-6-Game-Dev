extends Control
#Variables to be passed from actual game scenes
@export var monster_test: MonsterData
@export var player_test: PlayerData
#@export var Martial_art_attack: AttackData
#@export var Weapon_art_attack: AttackData

# End of data needed

@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"ActionContainer/Party-Members"
@onready var panel_container = $ActionContainer/ActionOptions
@onready var log_container = $ActionContainer/BattleLog

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
	DEFEAT
}
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_monster([monster_test])
	spawn_player([player_test])
	spawn_party_member_UI(players_array)

## Spawning Entities ##
func spawn_monster(monster_data: Array[MonsterData]):
	for monster in monster_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$EnemyContainer.add_child(unit)
		unit.setup(monster_data[monster], true)
		unit.global_position = enemy_slots[monster].global_position
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
		member_ui.action_selected.connect(_on_action_selected)
## UI Option Functionality ##
func clear_panel():
	for child in panel_container.get_children():
		child.queue_free()

func create_attack_buttons(unit: BattleUnit):
	clear_panel()
	battle_state = BattleState.SELECTING_ACTION
	for attack in unit.unit_data.attacks:
		var btn = Button.new()
		btn.text = attack.name
		btn.pressed.connect(_on_attack_selected.bind(unit, attack))
		panel_container.add_child(btn)
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
func check_battle_end():
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
		battle_state = BattleState.VICTORY
		log_container.text += "\n" + "Victory!"
		return true
	if living_player == 0:
		print("enemies all dead ")
		battle_state = BattleState.DEFEAT
		log_container.text += "\n" + "All Allies Slain..."
		return true
			
func handle_attack(text_display_actor, target_data, attack_data):
	if is_instance_valid(target_data):
		var target_name = target_data.unit_data.name
		var attack_name = attack_data.name
		target_data.take_damage(attack_data.damage)
		if target_data.current_hp <= 0:
			log_container.text += "\n" + target_name + " was Slain"
			return true
		else:
			log_container.text += "\n" + text_display_actor + " Used: " + attack_name + " on " + target_name

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
				action_obejct = {
					"type": "defend",
					"actor": unit
				}
				action_queue.push_back(action_obejct)
				resolve_turns()
			#"bag":
				#battle_state = BattleState.UTILITY
				#print(player.member_name, "Utility required...")
			"run":
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
			match action["type"]:
				"attack":
					handle_attack(text_display_actor, action["target"], action["attack"])
					if check_battle_end() == true:
						break
				"defend":
					handle_defense(text_display_actor, action["actor"])
				"run":
					handle_run(text_display_actor)

func resolve_turns():
	if battle_state != BattleState.VICTORY:
		monster_ai(enemies_array, players_array)
		execute_actions(action_queue)
		for unit in action_queue:
			unit["actor"].set_defending(false)
		action_queue.clear()
	else:
		print("Victory Condition Met!")
