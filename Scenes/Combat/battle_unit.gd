class_name BattleUnit
extends Node2D

signal unit_clicked(unit)

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Sprite2D/Area2D

var unit_data: Resource
var current_hp: int
var is_enemy: bool 
@export var defending = false
@export var temp_defense: int 
#temp stats

func _ready():
	area.input_event.connect(_on_input_event)

func setup(data: Resource, monster_flag: bool):
	is_enemy = monster_flag
	unit_data = data
	current_hp = unit_data.max_hp
	temp_defense = 0
	sprite.texture = unit_data.texture
	sprite.scale = Vector2(2, 2)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("unit_clicked", self)

func take_damage(amount: int):
	if defending == true:
		current_hp -= (amount/2)
	else:
		current_hp -= amount
	if current_hp <= 0:
		die()
		
func set_defending(value: bool):
	defending = value

func die():
	queue_free()
