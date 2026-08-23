extends Control

class_name BattleVisuals
#containers for preparing nodes to be populated
@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"UIContainer/ActionContainer/Party-Members"
@onready var panel_container = $"UIContainer/ActionContainer/ActionOptions"
@onready var log_container = $"UIContainer/ActionContainer/BattleLog"
@onready var minigame_container = $"UIContainer/ActionContainer/ActionOptions/Menu/Minigame"
@onready var containers = party_container.get_children()
@onready var party_selection = $"UIContainer/ActionContainer/Party-Members"
@onready var action_options = $"UIContainer/ActionContainer/ActionOptions"
@onready var menu_options = $"UIContainer/ActionContainer/ActionOptions/Menu"
@onready var move_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/MoveSelection"
@onready var inventory_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/InventorySelection"
@onready var attack_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/AttackSelection"
@onready var target_selection = $"UIContainer/ActionContainer/ActionOptions/Menu/TargetSelection"
@onready var active_player_border = $"UIContainer/ActionContainer/ActionOptions/Active_Player_Border"
@onready var active_player_slot = $"UIContainer/ActionContainer/ActionOptions/Active_Player_Border/selected_player"
@onready var active_player_back_button = $"UIContainer/ActionContainer/ActionOptions/Active_Player_Border/back_button"
@onready var action_button_handler = $UIContainer/ActionContainer/ActionOptions
var inventory = Global.Inventory
var member_uis = []

var selected_member = null
var unit = BattleUnit.new()
var players_array: Array[BattleUnit] = []
var enemies_array: Array[BattleUnit] = []
var active_player : BattleUnit
var selected_attack : AttackData
signal battle_end_condition(state)
signal current_action(action_object)

var battle_controller = BattleController.new()


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	battle_controller._current_action_listener(self)
	battle_controller.battle_queue_ready.connect(execute_phases)
	action_button_handler.battle_action_setup(self)
	action_button_handler.visual_battle_state.connect(_battle_visual_listener)

# Called when the node enters the scene tree for the first time.
func start_battle(player_data: Array[PlayerData], monser_data: Array[MonsterData]):
	spawn_monster(monser_data)
	spawn_player(player_data)
	spawn_party_member_UI()
	

func _battle_visual_listener(phase):
	match phase:
		0: #member selection phase
			child_clear(attack_selection)
			child_clear(inventory_selection)
			child_clear(target_selection)
			screen_panel_transition()
		1: # attack
			move_selection.hide()
			attack_selection.show()
			child_clear(attack_selection)
		2: # skill
			move_selection.hide()
			attack_selection.show()
			print("Need to work on visuals here + minigame transfer state")
		3: # item
			move_selection.hide()
			inventory_selection.show()
			#battle_visuals.action_options.show()
			#battle_visuals.menu_options.show()
			active_player_border.show()
		4: # run
			print("run function hasnt been implemented yet...")
		5: # defend
			move_selection.hide()
			screen_panel_transition()
		6: # Target selection
			attack_selection.hide()
			target_selection.show()


## Spawning Entities ##
func spawn_monster(monster_data: Array[MonsterData]):
	for i in range(monster_data.size()):
		var unit = load("res://Scenes/Combat/Entity_Data/Battle_Unit.tscn").instantiate()
		$EnemyContainer.add_child(unit)
		unit.setup(monster_data[i], true)
		unit.global_position = enemy_slots[i].global_position
		enemies_array.append(unit)

func spawn_player(player_data: Array[PlayerData]):
	for i in player_data.size():
		var unit = preload("res://Scenes/Combat/Entity_Data/Battle_Unit.tscn").instantiate()
		$PlayerContainer.add_child(unit)
		unit.setup(player_data[i], false)
		unit.global_position = player_slots[i].global_position
		players_array.append(unit)

func spawn_party_member_UI():
	for player in players_array:
		var member_ui = preload("res://Scenes/Combat/Player_Battle_GUI/PartyMemberUI.tscn").instantiate()
		for container in containers:
			if member_ui.get_parent() != null:
				continue
			else:
				container.add_child(member_ui)
		member_ui.setup(player)
		member_ui.selected.connect(_on_member_selected)
		member_uis.append(member_ui)
		#member_ui.action_selected.connect(_on_action_selected)

## Helper Functions ##
func child_clear(node: Node):
	for child in node.get_children():
		child.queue_free()

func screen_panel_transition():
	child_clear(active_player_slot)
	attack_selection.hide()
	action_options.hide()
	menu_options.hide()
	active_player_border.hide()
	move_selection.hide()
	target_selection.hide()
	party_selection.show()
	inventory_selection.hide()
	minigame_container.hide()
	
## Despawn Entities ##
func despawn_member_ui(party_member: BattleUnit):
	for member in member_uis:
		if party_member.unit_data.name == member.member_name:
			party_container.remove_child(member)

func death_check():
	for unit in players_array:
		if unit.current_hp <= 0:
			unit.die()
			party_container.remove_child(unit)
	for unit in enemies_array:
		if unit.current_hp <= 0:
			unit.die()
	
#party selection area
func _on_member_selected(member):
	print("Selecting:", member.member_name)
	party_container.hide()
	for player in players_array:
		if player.unit_data.name == member.member_name:
			active_player = player
		else:
			print("error occured and counlt match the player data")
			continue
	var active_member_ui = preload("res://Scenes/Combat/Player_Battle_GUI/PartyMemberUI.tscn").instantiate()
	active_player_slot.add_child(active_member_ui)
	active_member_ui.setup(active_player)
	#hide these after end of player phase
	action_options.show()
	menu_options.show()
	active_player_border.show()
	move_selection.show()
	

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
						party_member.set_member_values()
				death_check()
			"skill":
				print("skill being processed!")
				var target = phases["target"]
				if target.is_alive():
					target.take_damage(phases)
					for party_member in member_uis:
						party_member.set_member_values()
					#screen_panel_transition()
			# for bag add if clause for if no items in inventory bag should not count as action
			"bag":
				var actor = phases["actor"]
				if actor.is_alive():
					actor.inventory_use(phases)
					for party_member in member_uis:
						party_member.set_member_values()
				
