class_name BattleUnit
extends Node2D

signal unit_clicked(unit)

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Sprite2D/Area2D

var unit_name: String
var max_hp: int
var current_hp: int
var attack: int
var defense: int
var is_enemy: bool = false

func _ready():
	area.input_event.connect(_on_input_event)

func setup(data):
	if data == MonsterData:
		is_enemy = true
	unit_name = data.name
	max_hp = data.max_hp
	current_hp = max_hp
	attack = data.attack
	defense = data.defense
	sprite.texture = data.texture
	sprite.scale = Vector2(2, 2)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("unit_clicked", self)

func take_damage(amount: int):
	current_hp -= amount
	print(unit_name, "HP:", current_hp)

	if current_hp <= 0:
		die()

func die():
	queue_free()
