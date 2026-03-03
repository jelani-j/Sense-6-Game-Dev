extends Control
@onready var member_button1 = $MarginContainer/HBoxContainer/PartyMemberUi
#Variables to be passed from actual game scenes
@export var monster_test: MonsterData
@export var player_test: PlayerData
# End of data needed

@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $MarginContainer/MemberContainer

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
var players = []
var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_monster([monster_test])
	spawn_player([player_test])
	spawn_party_member([player_test])
	
func spawn_monster(monster_data: Array[MonsterData]):
	for i in monster_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$EnemyContainer.add_child(unit)
		unit.setup(monster_data[i])
		unit.global_position = enemy_slots[i].global_position

func spawn_player(player_data: Array[PlayerData]):
	for i in player_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$PlayerContainer.add_child(unit)
		unit.setup(player_data[i])
		unit.global_position = player_slots[i].global_position
	
# For First Button Press 
func spawn_party_member(players: Array[PlayerData]):
	for player in players:
		var member_ui = preload("res://Scenes/Combat/PartyMemberUI.tscn").instantiate()
		party_container.add_child(member_ui)
		member_ui.setup(player)
		member_ui.selected.connect(_on_member_selected)
		member_ui.action_selected.connect(_on_action_selected)
	
func _on_member_selected(member):
	if battle_state != BattleState.IDLE:
		return
	battle_state = BattleState.SELECTING_CHARACTER
	print("Selecting:", member.member_name)

func _on_action_selected(member, action):
	match action:
		"fight":
			battle_state = BattleState.SELECTING_ACTION
			print(member.member_name, "Engaging Target!")
		"defend":
			battle_state = BattleState.BLOCKING
			print(member.member_name, "Defending vitals...")
		"bag":
			battle_state = BattleState.UTILITY
			print(member.member_name, "Utility required...")
		"run":
			battle_state = BattleState.RUNNING
			print(member.member_name, "Retreating!")
		"skill":
			battle_state = BattleState.SPECIAL
			print(member.member_name, "Activating Special Ability!")
