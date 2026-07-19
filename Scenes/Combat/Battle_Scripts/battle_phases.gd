extends RefCounted
class_name BattlePhases

# think of better name for phases and standardize data here then send it all out over to battle_ui
func selection_phase(actor_data,target_data,damage_data):
	return {
		"type": "attack",
		"actor": actor_data,
		"target": target_data,
		"damage": damage_data
	}
func item_select_phase(actor, item, bag ):
	return{
		"type": "bag",
		"actor": actor,
		"item": item,
		"Inventory": bag
	}
		
func status_phase(status_data):
	return {
		"type": "status",
		"target": status_data["target"],
		"status": status_data["status"],
		"duration": status_data["duration"]
	}
	
#func damage_phase(phase):
	#status phase (statuses take effect before any turns are taken + applies damage if status is painful)
	# check for death phase (Grim Reaper)
	# action phase (player/ enemy actions)
	# execution phase( apply damage from attacks )
	# check for death phase (Grim Reaper)
	#end phase and restart unless gameover condition is reached
