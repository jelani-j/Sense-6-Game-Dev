#when listening for a signal with a script not attatched to a node it needs to be a resource
# that or a group either way normal listen logic does not apply for non attatched scripts
extends RefCounted
class_name BattleController

func _current_action_listener(battle_signal: Node) -> void:
	print("ready is being read")
	battle_signal.current_action.connect(_action_reciever)
	
	#battle_ui.current_action.connect(_action_reciever)
	
func _action_reciever(action: Dictionary):
	print("being reached!")
	print("Action recieved! ", action)
