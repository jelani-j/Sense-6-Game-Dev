extends Node2D

@onready var player_hitbox = $Main_Character/Area2D/CollisionShape2D
@onready var monster = $Monster
@onready var battle_UI = $CanvasLayer/BattleUI
# Called when the node enters the scene tree for the first time.
func _ready():
	monster.battle_triggered.connect(_on_battle_triggered)
	battle_UI.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_battle_triggered():
	print("Battle!")
	battle_UI.show()
	
