extends BattleController
	
#func action_interpreter(action_queue):
#for action in action_queue:
	#if is_instance_valid(action["actor"]):
		#var text_display_actor = action["actor"].unit_data.name
		#var actor_data = action["actor"].unit_data
		#match action["type"]:
			#"attack":
				#if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
					#continue
				#handle_attack(text_display_actor, action["target"], action["attack"], actor_data)
			#"defend":
				#handle_defense(text_display_actor, action["actor"])
			#"bag":
				#var item = action["item"]
				#var bag = action["bag"]
				#var actor = action["actor"]
				#log_container.text += "\n" + text_display_actor + " is Using: " + item.name
				#bag.use_item(item, actor)
			#"run":
				#handle_run(text_display_actor)
				#battle_state = BattleState.ESCAPED
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
