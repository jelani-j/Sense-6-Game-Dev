extends RefCounted
class_name ActionInterpreter
var minigame = AttackMinigame.new()
var damage_calc = ActionPhase.new()
var status_effects = StatusProcessing.new()
var minigame_result
var battle_phases = BattlePhases.new()
var monster_ai = MonsterAi.new()


func action_interpreter(action_queue, enemies, players,minigame_container):
	var battle_queue = []
	for action in action_queue:
		if is_instance_valid(action["actor"]):
			var actor_data = action["actor"]
			var status_data
			var interaction_data
			match action["type"]:
				"attack":
					print(actor_data.unit_data.name, " is hitting ", action["target"].unit_data.name)
					var attack_data = action["move"]
					var target_data = action["target"]
					var damage_data = damage_calc.calculate_damage(attack_data,actor_data,target_data)
					status_data = status_effects.trigger_status(target_data,attack_data)
					if status_data:
						battle_queue.append(battle_phases.status_phase(status_data))
					battle_queue.append(battle_phases.selection_phase(actor_data,target_data,damage_data))
					#minigame will be reinstated later after it has been re-established
					#minigame_result = await minigame.mini_game_func(minigame_container)
					
					#if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
						#continue
				"defend":
					print("Defend interpreted")
					status_data = status_effects.apply_status(actor_data,StatusTypes.STATUS.Defend, 1)
					battle_queue.append(battle_phases.status_phase(status_data))

				"bag":
					var item = action["item"]
					var bag = action["Inventory"]
					var actor = action["actor"]
					battle_queue.append(battle_phases.item_select_phase(actor,item,bag))
				#"run":
					#handle_run(text_display_actor)
					#battle_end_condition.emit(battle_state)
					#despawn_member_ui(action["actor"])
	return battle_queue
