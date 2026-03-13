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
	SPECIAL
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
	spawn_party_member(players_array)
	
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
	
## For First Button Press 
func spawn_party_member(players_array):
	for player in players_array:
		var member_ui = preload("res://Scenes/Combat/PartyMemberUI.tscn").instantiate()
		party_container.add_child(member_ui)
		member_ui.setup(player)
		member_ui.selected.connect(_on_member_selected)
		member_ui.action_selected.connect(_on_action_selected)
	#
func _on_member_selected(member):
	if battle_state != BattleState.IDLE:
		return
	battle_state = BattleState.SELECTING_CHARACTER
	print("Selecting:", member.member_name)
#
func clear_panel():
	for child in panel_container.get_children():
		child.queue_free()
#
func create_attack_buttons(unit: BattleUnit):
	clear_panel()
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
#
func show_targets(targets: Array[BattleUnit]):
	for target in targets:
		var monster_target = Button.new()
		monster_target.text = target.unit_data.name
		panel_container.add_child(monster_target)
		monster_target.pressed.connect(attack_target.bind(target, selected_attack))

func monster_ai(enemies_array, players_array):
	for monster in enemies_array:
		action_obejct = {
			"type": "attack",
			"actor": monster,
			"target": players_array[0],
			"attack": monster.unit_data.attacks[0]
		}
		action_queue.push_back(action_obejct)

func execute_actions(action_queue):
	for action in action_queue:
		var user = action["actor"].unit_data.name
		
		if action["type"] == "attack":
			var target = action["target"].unit_data.name
			var attack_name = action["attack"].name
			log_container.text += "\n" + user + " Used: " + attack_name + " on " + target
			action.target.take_damage(action["attack"].damage)
		if action["type"] == "defend":
			print(user, " is Defending")
		if action["type"] == "run":
			log_container.text += "\n" + user + "is Running away!"
	

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
	start_queue()
		
func _on_action_selected(unit, action):
	print("Current Defense: ", unit.unit_data.defense)
	match action:
		"fight":
			battle_state = BattleState.SELECTING_ACTION
			create_attack_buttons(unit)
		"defend":
			battle_state = BattleState.BLOCKING
			action_obejct = {
				"type": "defend",
				"actor": unit
			}
			action_queue.push_back(action_obejct)
			execute_actions(action_queue)
			start_queue()
		#"bag":
			#battle_state = BattleState.UTILITY
			#print(player.member_name, "Utility required...")
		"run":
			battle_state = BattleState.RUNNING
			action_obejct = {
				"type": "run",
				"actor": unit
			}
			action_queue.push_back(action_obejct)
			execute_actions(action_queue)
			start_queue()
			#print(action_queue)
		#"skill":
			#battle_state = BattleState.SPECIAL
			#print(player.member_name, "Activating Special Ability!")
func start_queue():
	monster_ai(enemies_array, players_array)
	execute_actions(action_queue)
	action_queue.clear()
