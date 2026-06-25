extends Node

#need to add handle death here or have another area to implement minigame await as if its here it will cause a delay in death
func damage_phase(action_queue, mini_game_results):
	for action in action_queue:
		if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
			continue
		if action["type"] != "attack":
			continue
		var attack_data = action["attack"]
		var target_data = action["target"]
		var actor_data = action["actor"].unit_data
		var power = actor_data.attack
		target_data.process_attack(attack_data, power, target_data.unit_data.defense, mini_game_results)
		await get_tree().create_timer(0.2).timeout  
		
