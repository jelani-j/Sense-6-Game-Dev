extends Node

func apply_status_effect():
	for action in action_queue:
		if action["type"] != "attack":
			continue
		var attack_data = action["attack"]
		if attack_data["status"] == null:
			print(attack_data["status"])
			continue
		print("reaching status effect apply")
		var status_effect = attack_data["status"]
		var target = action["target"]
		#if randf() <= attack_data.status_chance:
		if attack_data.status_chance != null:
			target.add_status({"status": attack_data.status, "duration": 1})

func status_effect_phase():
	var all_units = enemies_array + players_array
	for unit in all_units:
		var status_effects = unit.get_status()
		if status_effects.is_empty():
			continue
		for i in range(status_effects.size() - 1, -1, -1):
			var effect = status_effects[i]
			var status = effect["status"]
			match status:
				"Stun":
					unit.status_damage("Stun")
				"Bleeding":
					print("you are Bleeding!")
					unit.status_damage("Bleeding")
				"Poison":
					print("you are Poisioned!")
					unit.status_damage("Poison")
				"Fire":
					unit.status_damage("Fire")
				"Electrified":
					unit.status_damage("Electrified")
				"Soul Shatterd":
					unit.status_damage("Soul Shattered")
					
			effect["duration"] -= 1
			if effect["duration"] <= 0:
				unit.clear_status()
		print(status_effects)
