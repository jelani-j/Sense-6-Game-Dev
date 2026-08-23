extends PanelContainer

@onready var party_container = $"UIContainer/ActionContainer/Party-Members"
@onready var panel_container = $"UIContainer/ActionContainer/ActionOptions"
@onready var containers = party_container.get_children()
var member_uis
var players_array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func party_member_setup(ui_array,player_array):
	member_uis = ui_array
	players_array = player_array

## Despawn Entities ##
func despawn_member_ui(party_member: BattleUnit):
	for member in member_uis:
		if party_member.unit_data.name == member.member_name:
			party_container.remove_child(member)
			

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
