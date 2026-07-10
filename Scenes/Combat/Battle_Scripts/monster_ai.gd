extends RefCounted
class_name MonsterAi

## Monster AI Functionality ##
func monster_ai(enemies_array, players_array):
	for monster in enemies_array:
		if is_instance_valid(monster) and monster.is_alive():
			return{
				"type": "attack",
				"actor": monster,
				"target": players_array[0],
				"attack": monster.unit_data.attacks[0]
			}
