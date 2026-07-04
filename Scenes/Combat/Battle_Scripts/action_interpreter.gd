extends RefCounted
class_name ActionInterpreter
var minigame = AttackMinigame.new()
var damage_calc = ActionPhase.new()
var status_effects = StatusProcessing.new()
var minigame_result
var battle_sequencer = BattlePhases.new()

func action_interpreter(action_queue, enemies, players,minigame_container):
	for action in action_queue:
		if is_instance_valid(action["actor"]):
			var actor_data = action["actor"]
			var status_data
			match action["type"]:
				"attack":
					print("initiating attack")
					var attack_data = action["move"]
					var target_data = action["target"]
					damage_calc.calculate_damage(attack_data,actor_data,target_data)
					status_data = status_effects.trigger_status(target_data,attack_data)
					battle_sequencer.status_phase(status_data)
					#minigame will be reinstated later after it has been re-established
					#minigame_result = await minigame.mini_game_func(minigame_container)
					#if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
						#continue
				"defend":
					print("Defend interpreted")
					status_data = status_effects.apply_status(actor_data,StatusTypes.STATUS.Defend, 1)
					battle_sequencer.status_phase(status_data)
					
					#handle_defense(text_display_actor, action["actor"])
				#"bag":
					#var item = action["item"]
					#var bag = action["bag"]
					#var actor = action["actor"]
					#bag.use_item(item, actor)
				#"run":
					#handle_run(text_display_actor)
					#battle_end_condition.emit(battle_state)
					#despawn_member_ui(action["actor"])
#
#func inventory_use(item: ItemData, bag: InventoryData, unit: BattleUnit):
	#action_obejct = {
		#"type": "bag",
		#"actor": unit,
		#"item": item,
		#"bag": bag
	#}
	#action_queue.push_back(action_obejct)
	#clear_panel()
	#resolve_turns()
#
#func attack_target(target: BattleUnit, attack: AttackData):
	#battle_state = BattleState.EXECUTING
	#clear_panel()
	#action_obejct = {
		#"type": "attack",
		#"actor": active_player,
		#"target": target,
		#"attack": selected_attack
	#}
	#action_queue.push_back(action_obejct)
	#resolve_turns()
