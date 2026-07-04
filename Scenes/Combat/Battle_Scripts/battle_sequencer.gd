extends RefCounted
class_name BattlePhases
# will need to have access to directly send info to battle ui, and have phases affect units 

func status_phase(phase):
	return phase
		
func player_phase(phase):
		return phase
		
func enemy_pahse(phase):
	return phase
	#status phase (statuses take effect before any turns are taken + applies damage if status is painful)
	# check for death phase (Grim Reaper)
	# action phase (player/ enemy actions)
	# execution phase( apply damage from attacks )
	# check for death phase (Grim Reaper)
	#end phase and restart unless gameover condition is reached
