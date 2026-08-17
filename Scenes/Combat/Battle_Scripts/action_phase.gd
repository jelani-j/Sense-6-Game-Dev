extends RefCounted
class_name ActionPhase
#need to add handle death here or have another area to implement minigame await as if its here it will cause a delay in death
var minigame_result

func skill_results_capture(result):
	minigame_result = result

func calculate_damage(attack_data: AttackData, actor, target):
	var amount = attack_data.damage
	var power = actor.unit_data.attack
	var target_def = target.unit_data.defense
	var accuracy: int
	if minigame_result == "perfect":
		accuracy = 2
	#elif minigame_result == "good":
		#accuracy = 1
	else:
		minigame_result = "missed"
		accuracy = 0
	#var damage_calc = accuracy + ((amount + power) - def)
	var damage_calc = ((amount + power + accuracy) - target_def)
	#if statemnet here is causing some form of timing issue
	#if defending:
		#print("Defending")
		#current_hp -= round((player_damage_calc * 0.70))
		#print(round(player_damage_calc * 0.70))
	#current_hp -= player_damage_calc
	return damage_calc

func inventory_use(item: ItemData, bag: InventoryData, target: BattleUnit):
	return 
