extends Control

enum BattleState {
	IDLE,
	SELECTING_CHARACTER,
	SELECTING_ACTION,
	TARGETING,
	EXECUTING
}
var battle_state := BattleState.IDLE
var selected_member = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
