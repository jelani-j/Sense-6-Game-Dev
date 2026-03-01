extends Control
@onready var member_button1 = $MarginContainer/HBoxContainer/PartyMemberUi

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
	pass

# For First Button Press 
func _process(delta: float) -> void:
	pass

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
