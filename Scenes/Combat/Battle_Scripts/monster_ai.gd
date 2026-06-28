extends RefCounted

## Monster AI Functionality ##
func monster_ai(enemies_array, players_array):
	for monster in enemies_array:
		if is_instance_valid(monster) and monster.is_alive():
			action_queue.push_back({
				"type": "attack",
				"actor": monster,
				"target": players_array[0],
				"attack": monster.unit_data.attacks[0]
			})
