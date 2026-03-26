extends Node2D

@onready var player_hitbox = $Main_Character/Area2D/CollisionShape2D
var battle_scene = preload("res://Scenes/Combat/Battle_Ui_Scene.tscn")
var battle_initiated = false
var battle_canvas
var current_monster
var monster_scene = preload("res://Resource Items/Monsters/monster.tscn")
var monsters_spawned = []
@onready var monster_spawn_point = $Monster_spawn_point1
var goblin_data: MonsterData = load("res://Resource Items/Monsters/goblin.tres")
var player_data: PlayerData = load("res://Resource Items/Players/main_character.tres")
var battle_instance

func _ready():
	monster_spawn([goblin_data])
	mosnter_interactions(monsters_spawned)
	#monster_scene.battle_triggered.connect(_on_battle_triggered)

func monster_spawn(monsters: Array[MonsterData]):
	for monster in monsters:
		var monster_instance = monster_scene.instantiate()
		add_child(monster_instance)
		monster_instance.setup(monster, 25.0)
		monster_instance.global_position = monster_spawn_point.global_position
		monsters_spawned.append(monster_instance)

func mosnter_interactions(monsters_spawned):
	for monster in monsters_spawned:
		monster.battle_triggered.connect(_on_battle_triggered.bind(monster))
	
func _on_battle_triggered(monster):
	if battle_initiated:
		return
	battle_initiated = true
	current_monster = monster
	current_monster.set_deferred("monitoring", false)
	call_deferred("_start_battle")

func _start_battle():
	battle_canvas = CanvasLayer.new()
	add_child(battle_canvas)
	
	battle_instance = battle_scene.instantiate()
	battle_canvas.add_child(battle_instance)
	var players: Array[PlayerData] = [player_data]
	var enemies: Array[MonsterData] = current_monster.get_encounter_data()
	battle_instance.start_battle(players, enemies)
	battle_instance.battle_end_condition.connect(_battle_check)
	await get_tree().process_frame
	get_tree().paused = true

func _battle_check(battlestate):
	match battlestate:
		9:
			print("You Won!")
			despawn_battle_ui()
			current_monster.despawn()
		10:
			print("Fainted")
			despawn_battle_ui()
		11:
			print("you got away")
			despawn_battle_ui()

func despawn_battle_ui():
	get_tree().paused = false
	battle_canvas.queue_free()
