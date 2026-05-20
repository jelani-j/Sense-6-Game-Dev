extends Node2D
# Loading all needed scenes & variables for map
var battle_scene = preload("res://Scenes/Combat/Battle_Ui_Scene.tscn")
var battle_initiated = false
var battle_canvas
var current_monster
var current_player
var monster_scene = preload("res://Resource Items/Monsters/monster.tscn")
var player_scene = preload("res://Resource Items/Players/player.tscn")
var item_scene = preload("res://Resource Items/Inventory/item.tscn")
var monsters_spawned = []
#Spawner markers for all entities
@onready var player_spawn_point = $Player_Spawn
@onready var item_spawn_point = $Item_Spawn_1

#resources to load everytime, monster, player, and item data
var luminete_data: MonsterData = load("res://Resource Items/Monsters/Luminete.tres")
var skitterfang_data: MonsterData = load("res://Resource Items/Monsters/SkitterFang.tres")
var greyscale_data: MonsterData = load("res://Resource Items/Monsters/Greyscale.tres")
var stalagbat_data: MonsterData = load("res://Resource Items/Monsters/Stalagbat.tres")
var player_data: PlayerData = load("res://Resource Items/Players/main_character.tres")
var bepzi: ItemData = load("res://Resource Items/Inventory/bepzi.tres")
var battle_instance

#spawn list for all the monsters and data associated with them
@onready var spawn_list = {
	"luminete": {"data": [luminete_data, luminete_data] as Array[MonsterData], "position": $Luminete_Spawner},
	"skitterfang": {"data": [skitterfang_data] as Array[MonsterData], "position": $SkitterFang_Spawner},
	"greyscale": {"data": [greyscale_data] as Array[MonsterData], "position": $GreyScale_Spawner},
	"stalagbat": {"data": [stalagbat_data] as Array[MonsterData], "position": $Stalagbat_Spawner}
}

func _ready():
	player_spawn(player_data)
	item_spawn([bepzi])
	monster_spawn(spawn_list)
	monster_interactions(monsters_spawned)

func player_spawn(player: PlayerData):
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.setup(player)
	player_instance.global_position = player_spawn_point.global_position

func item_spawn(items: Array[ItemData]):
	for item in items:
		var item_instance = item_scene.instantiate()
		add_child(item_instance)
		item_instance.setup(item)
		item_instance.global_position = item_spawn_point.global_position
		print("item spawned!")

func monster_spawn(monsters: Dictionary):
	for monster in monsters:
		var monster_entity = monsters[monster]
		var monster_instance = monster_scene.instantiate()
		var encounter_data = monster_entity["data"]
		add_child(monster_instance)
		monster_instance.setup(encounter_data, 25.0)
		monster_instance.global_position = monster_entity["position"].global_position
		monsters_spawned.append(monster_instance)

func monster_interactions(monsters_spawned):
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
