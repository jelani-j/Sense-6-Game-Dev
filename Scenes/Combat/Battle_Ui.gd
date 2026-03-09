extends Control
#Variables to be passed from actual game scenes
@export var monster_test: MonsterData
@export var player_test: PlayerData
@export var Martial_art_attack: AttackData
@export var Weapon_art_attack: AttackData

# End of data needed

@onready var enemy_slots = $EnemyContainer.get_children()
@onready var player_slots = $PlayerContainer.get_children()
@onready var party_container = $"ActionContainer/Party-Members"
@onready var panel_container = $ActionContainer/ActionOptions

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
var players_array = []
var enemies_array = []
var targetable_enemies = []
var active_player : PlayerData
var selected_attack : AttackData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_monster([monster_test])
	spawn_player([player_test])
	spawn_party_member([player_test])
	
func spawn_monster(monster_data: Array[MonsterData]):
	for monster in monster_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$EnemyContainer.add_child(unit)
		unit.setup(monster_data[monster])
		unit.global_position = enemy_slots[monster].global_position
		#enemies_array.append(monster_data[monster])
		enemies_array.append(unit)

func spawn_player(player_data: Array[PlayerData]):
	for i in player_data.size():
		var unit = preload("res://Scenes/Combat/Battle_Unit.tscn").instantiate()
		$PlayerContainer.add_child(unit)
		unit.setup(player_data[i])
		unit.global_position = player_slots[i].global_position
		#players_array.append(player_data[i])
		players_array.append(unit)
	
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

func clear_panel():
	for child in panel_container.get_children():
		child.queue_free()

func create_attack_buttons(player: PlayerData):
	clear_panel()
	for attack in player.attacks:
		var btn = Button.new()
		btn.text = attack.name
		btn.pressed.connect(_on_attack_selected.bind(player, attack))
		panel_container.add_child(btn)


	
func _on_attack_selected(player: PlayerData, attack: AttackData):
	print(player.name, ": used -->", attack.name)
	battle_state = BattleState.TARGETING
	active_player = player
	selected_attack = attack
	clear_panel()
	show_targets()

func show_targets():
	for enemy in enemies_array:
		var monster_target = Button.new()
		monster_target.text = enemy.unit_name
		panel_container.add_child(monster_target)
		monster_target.pressed.connect(attack_target.bind(enemy, selected_attack))

func attack_target(target: BattleUnit, attack: AttackData):
	battle_state = BattleState.EXECUTING
	clear_panel()
	target.take_damage(attack.damage)
	print(target.name, "has: ", target.current_hp, " HitPoints left" )
	#if target.max_hp >=0:
		#print (target.name, " has been slain!")
		#despawn_monster(target)
		
func _on_action_selected(player_data, action):
	match action:
		"fight":
			battle_state = BattleState.SELECTING_ACTION
			create_attack_buttons(player_data)
			print( "Engaging Target!")
			
		#"defend":
			#battle_state = BattleState.BLOCKING
			#print(player.member_name, "Defending vitals...")
		#"bag":
			#battle_state = BattleState.UTILITY
			#print(player.member_name, "Utility required...")
		#"run":
			#battle_state = BattleState.RUNNING
			#print(player.member_name, "Retreating!")
		#"skill":
			#battle_state = BattleState.SPECIAL
			#print(player.member_name, "Activating Special Ability!")
