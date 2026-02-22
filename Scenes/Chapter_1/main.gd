extends Node2D

@onready var player_hitbox = $Main_Character/Area2D/CollisionShape2D
@onready var monster = $Monster
@onready var battle_UI = $CanvasLayer/BattleUI
var goblin_sprite = preload("res://Sprite_Textures/Sprite_template_tests/DebtsInTheDepthsAssets/Characters/goblin.tres")# Called when the node enters the scene tree for the first time.

func _ready():
	monster.setup(goblin_sprite, 25.0)
	monster.battle_triggered.connect(_on_battle_triggered)
	battle_UI.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_battle_triggered():
	print("Battle!")
	battle_UI.show()
	
