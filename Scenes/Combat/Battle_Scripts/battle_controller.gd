#when listening for a signal with a script not attatched to a node it needs to be a refcounted
# that or a group either way normal listen logic does not apply for non attatched scripts
extends RefCounted
class_name BattleController

var action_queue = []
var battle_queue = []
var interpreter = ActionInterpreter.new()
var monsters = MonsterAi.new()
var player_array
var enemy_array
var minigame_container
signal battle_queue_ready(queue)
	
func _current_action_listener(battle_signal: Node) -> void:
	battle_signal.current_action.connect(_action_reciever)
	player_array = battle_signal.players_array
	enemy_array = battle_signal.enemies_array
	minigame_container = battle_signal.minigame_container
	
func _action_reciever(action: Dictionary):
	action_queue.append(action)
	process_action()

func process_action():
	battle_queue.clear()
	var monster_action = monsters.monster_ai(enemy_array,player_array, minigame_container)
	battle_queue += interpreter.action_interpreter(action_queue,enemy_array,player_array,minigame_container)
	battle_queue += interpreter.action_interpreter(monster_action,enemy_array,player_array,minigame_container)
	action_queue.clear()
	battle_queue_ready.emit(battle_queue)
	

# after recieving action determine how action should be processed
# after sending it to be procssed the interpreter should handle the actual actions of the queue happening
# this simply builds the queue ain order and directs the objects where to go 

#if attack: --> minigame --> action_phase --> interpreter
#if run: --> interpreter 
#if defense: --> action_phase --> interpreter
# if bag --> interpreter

# after everything has ran through the interpreter have it passed back and finalized here
# send that over to the UI in order for it to take effect. this acts as brdige between UI and actions
