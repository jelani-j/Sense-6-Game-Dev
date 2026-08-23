extends VBoxContainer
class_name BattleActions

var inventory = Global.Inventory

var selected_attack : AttackData
var active_player : BattleUnit
var battle_visuals
var action_queue = []
var action_object: Dictionary = {}
signal current_action(action_object)
signal visual_battle_state(phase)
enum Battle_State_Screen{
		MEMBER_SELECTION_PHASE,
		ATTACK_SELECTION_PHASE,
		SKILL_SELECTION_PHASE,
		ITEM_SELECTION_PHASE,
		RUN_SELECTION_PHASE,
		DEFEND_SELECTION_PHASE,
		TARGET_SELECTION_PHASE
	}
# Called when the node enters the scene tree for the first time.
func battle_action_setup(battle_ui_data) -> void:
	battle_visuals = battle_ui_data


## Button Presses ##
func _on_back_button_pressed() -> void:
	visual_battle_state.emit(Battle_State_Screen.MEMBER_SELECTION_PHASE)

func _on_fight_pressed() -> void:
	visual_battle_state.emit(Battle_State_Screen.ATTACK_SELECTION_PHASE)
	create_attack_buttons(battle_visuals.active_player)

func _on_def_pressed() -> void:
	visual_battle_state.emit(Battle_State_Screen.DEFEND_SELECTION_PHASE)
	trigger_defense(battle_visuals.active_player)

func _on_run_pressed() -> void:
	battle_visuals.move_selection.hide()
	trigger_run(active_player)

func _on_bag_pressed() -> void:
	visual_battle_state.emit(Battle_State_Screen.ITEM_SELECTION_PHASE)
	show_inventory(inventory, battle_visuals.active_player)

func _on_skill_pressed() -> void:
	visual_battle_state.emit(Battle_State_Screen.SKILL_SELECTION_PHASE)
	#minigame_container.show()
	#child_clear(minigame_container)
	create_skill_attack_buttons(battle_visuals.active_player)

func _on_flow_pressed() -> void:
	pass # Replace with function body. [ implement flow state after multiple good scored skills]


## On Button clicked reactions ##
func create_attack_buttons(unit: BattleUnit):
	for attack in unit.unit_data.attacks:
		var attack_btn = Button.new()
		attack_btn.text = attack.name
		attack_btn.pressed.connect(_on_attack_selected.bind(unit, attack))
		battle_visuals.attack_selection.add_child(attack_btn)


func create_skill_attack_buttons(unit):
	battle_visuals.child_clear(battle_visuals.attack_selection)
	for skill in unit.unit_data.skills:
		var skill_btn = Button.new()
		skill_btn.text = skill.name
		battle_visuals.attack_selection.add_child(skill_btn)
		if unit.current_meter < skill.cost:
			print("Build more Meter before use!")
		else:
			skill_btn.pressed.connect(_on_skill_selected.bind(unit, skill))

#consider if this should be moved over to visual, and mainly just emit attack signal + details
func _on_attack_selected(player: BattleUnit, attack: AttackData):
	active_player = player
	selected_attack = attack
	var attack_buttons = battle_visuals.attack_selection.get_children()
	for button in attack_buttons:
		battle_visuals.attack_selection.remove_child(button)
	show_targets(battle_visuals.enemies_array)
	visual_battle_state.emit(Battle_State_Screen.TARGET_SELECTION_PHASE)

func _on_skill_selected(player: BattleUnit, attack: SkillData):
	active_player = player
	selected_attack = attack
	battle_visuals.child_clear(battle_visuals.attack_selection)
	battle_visuals.attack_selection.hide()
	battle_visuals.target_selection.show()
	show_targets(battle_visuals.enemies_array)

func show_targets(targets: Array[BattleUnit]):
	for target in targets:
		if is_instance_valid(target):
			var monster_target = Button.new()
			monster_target.text = target.unit_data.name
			battle_visuals.target_selection.add_child(monster_target)
			if selected_attack is AttackData:
				monster_target.pressed.connect(trigger_attack.bind(target, selected_attack))
			if selected_attack is SkillData:
				monster_target.pressed.connect(trigger_skill.bind(target, selected_attack))


## Processing actions & Sending out action object for Processing
func trigger_attack(target, selected_attack):
	if is_instance_valid(target):
		var target_name = target.unit_data.name
		var attack_name = selected_attack.name
		battle_visuals.log_container.text += "\n" + active_player.unit_data.name  + " Used: " + attack_name + " on " + target_name
		action_object = {
			"type": "attack",
			"actor": active_player,
			"move": selected_attack,
			"target": target
		}
		battle_visuals.child_clear(battle_visuals.target_selection)
		battle_visuals.screen_panel_transition()
		current_action.emit(action_object)

func trigger_skill(target, selected_attack):
	if is_instance_valid(target):
		var target_name = target.unit_data.name
		var skill_name = selected_attack.name
		battle_visuals.log_container.text += "\n" + active_player.unit_data.name  + " Used: " + skill_name + " on " + target_name
		action_object = {
			"type": "skill",
			"actor": active_player,
			"move": selected_attack,
			"target": target
		}
		battle_visuals.child_clear(battle_visuals.target_selection)
		battle_visuals.target_selection.hide()
		#show minigame and await action before sending out data 
		battle_visuals.minigame_container.show()
		current_action.emit(action_object)

func trigger_defense(actor):
	battle_visuals.log_container.text += "\n" + actor.unit_data.name + " is Defending"
	action_object = {
		"type": "defend",
		"actor": actor
	}
	current_action.emit(action_object)
	visual_battle_state.emit(Battle_State_Screen.DEFEND_SELECTION_PHASE)

func trigger_run(actor):
	battle_visuals.log_container.text += "\n" + actor.unit_data.name + " is Running away!"
	action_object = {
		"type": "run",
		"actor": actor
	}
	battle_visuals.screen_panel_transition()
	current_action.emit(action_object)
	visual_battle_state.emit(Battle_State_Screen.RUN_SELECTION_PHASE)

func show_inventory(bag: InventoryData, unit):
	for slot in bag.slots:
		var slot_button = Button.new()
		slot_button.text = slot.item.name + " x" + str(slot.quantity)
		battle_visuals.inventory_selection.add_child(slot_button)
		slot_button.pressed.connect(send_inventory_data.bind(slot.item, bag, unit))
		
func send_inventory_data(item, bag, unit):
	action_object = {
			"type": "bag",
			"Inventory": bag,
			"actor": unit,
			"item": item
		}
	battle_visuals.screen_panel_transition()
	battle_visuals.child_clear(battle_visuals.inventory_selection)
	current_action.emit(action_object)
