extends RefCounted
class_name StatusProcessing

var current_status
var status_object: Dictionary
var status_damage

func trigger_status(target,attack: AttackData):
	var status = attack.status
	var status_chance = attack.status_chance
	print(status, " from attack has a ", status_chance * 100, " % of being triggered")
	if randf() < status_chance:
		print("Status Triggered!")
		apply_status(target,status, 1)
	else:
		return

func apply_status(target,status, duration):
	match status:
		StatusTypes.STATUS.Defend:
			return finalize_status(target,status, duration)
		StatusTypes.STATUS.Poison:
			tick_damage(target,status, duration)
		StatusTypes.STATUS.Stun:
			stun()
		StatusTypes.STATUS.SoulShattered:
			print("this will be added later")
			# implement this one later 4 stacks = great chunck of damage 
		StatusTypes.STATUS.Bleeding:
			tick_damage(target,status, duration)
		StatusTypes.STATUS.Fire:
			tick_damage(target,status, duration)
		StatusTypes.STATUS.Electrified:
			print("this will be added later")
			# add later disable defending 
	
func stun():
	#skip turn or phase here for duration 
	print("skipping turn")
	
func tick_damage(target,status,duration):
	# later split this to burn poision and bleed to do different things for now just reduce hp by 1
	print("applying tick damage")
	status_damage = 1
	return finalize_status(target,status, duration)
	

func finalize_status(target,status, duration) -> Dictionary:
	#return dictonary with status, effect(damage/edits), and duration
	status_object = {
		"type": "status",
		"target": target,
		"status": status,
		"duration": duration,
		"damage": status_damage
	}
	return status_object
