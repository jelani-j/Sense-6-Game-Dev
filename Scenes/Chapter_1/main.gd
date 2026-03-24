extends Node2D

@onready var player_hitbox = $Main_Character/Area2D/CollisionShape2D
@onready var monster = $Monster
var goblin_sprite = preload("res://Sprite_Textures/Sprite_template_tests/DebtsInTheDepthsAssets/Characters/goblin.tres")# Called when the node enters the scene tree for the first time.
var battle_scene = preload("res://Scenes/Combat/Battle_Ui_Scene.tscn")
var battle_initiated = false
var battle_canvas
var current_monster
var monster_data: MonsterData = load("res://Resource Items/Monsters/goblin.tres")
var player_data: PlayerData = load("res://Resource Items/Players/main_character.tres")
var battle_instance

func _ready():
	monster.setup(goblin_sprite, 25.0)
	monster.battle_triggered.connect(_on_battle_triggered)

func _on_battle_triggered():
	if battle_initiated:
		return
	battle_initiated = true
	monster.set_deferred("monitoring", false)
	call_deferred("_start_battle")

func _start_battle():
	battle_canvas = CanvasLayer.new()
	add_child(battle_canvas)
	
	battle_instance = battle_scene.instantiate()
	battle_canvas.add_child(battle_instance)
	var players: Array[PlayerData] = [player_data]
	var enemies: Array[MonsterData] = [monster_data]
	battle_instance.start_battle(players, enemies)
	battle_instance.battle_end_condition.connect(_battle_check)
	await get_tree().process_frame
	get_tree().paused = true

func _battle_check(battlestate):
	match battlestate:
		9:
			print("You Won!")
			despawn_battle_ui()
		10:
			print("Fainted")
			despawn_battle_ui()
		11:
			print("you got away")
			despawn_battle_ui()

func despawn_battle_ui():
	get_tree().paused = false
	battle_canvas.queue_free()

#func on_battle_end():
	#battle_UI.clear_panel()
	
