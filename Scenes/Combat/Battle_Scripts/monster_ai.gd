extends RefCounted
class_name MonsterAi

#var interpreter = ActionInterpreter.new()

## Monster AI Functionality ##
func monster_ai(enemies_array, players_array, minigame_container):
	for monster in enemies_array:
		if is_instance_valid(monster) and monster.is_alive():
			print("monster Ai being hit and trying to return attck data!")
			return [{
				"type": "attack",
				"actor": monster,
				"target": players_array[0],
				"move": monster.unit_data.attacks[0]
			}]
			#interpreter.monster_action_interpreter(monster_action_queue, enemies_array, players_array)
