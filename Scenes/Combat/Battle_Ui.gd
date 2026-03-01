extends Control
@onready var member_button1 = $MarginContainer/HBoxContainer/PartyMemberUi
@export var monster_test: MonsterData
@export var player_test: PlayerData
@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()

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
func _process(delta: float) -> void:
	pass

#Spawn in enemies & players into scene 


# Button logic for party member ui
func _on_party_member_ui_pressed() -> void:
	if battle_state != BattleState.IDLE:
		return
	battle_state = BattleState.SELECTING_CHARACTER
	print(battle_state)
	
func _on_party_member_ui_fight() -> void:
	battle_state = BattleState.SELECTING_ACTION
	print(battle_state,"Engaging Target!")

func _on_party_member_ui_defend() -> void:
	battle_state = BattleState.BLOCKING
	print(battle_state,"Defending vitals...")

func _on_party_member_ui_bag() -> void:
	battle_state = BattleState.UTILITY
	print(battle_state, "Utility required...")

func _on_party_member_ui_run() -> void:
	battle_state = BattleState.RUNNING
	print(battle_state,"Retreating!")

func _on_party_member_ui_skill() -> void:
	battle_state = BattleState.SPECIAL
	print(battle_state,"Activating Special Ability!")
