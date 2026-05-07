extends CharacterBody2D

var data: PlayerData
const SPEED = 200.0
@onready var sprite: Sprite2D = $Sprite2D

func setup(Player_Data: PlayerData):
	data = Player_Data
	sprite.texture = data.texture
	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED
	
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	
	
