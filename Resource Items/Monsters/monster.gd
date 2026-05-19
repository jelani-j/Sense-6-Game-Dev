extends CharacterBody2D


var speed = 25.0
var player_chase = false
var player = null
var data: MonsterData
signal battle_triggered
@onready var animated_sprite: Sprite2D = $AnimatedSprite2D
@export var texture: Texture2D

func setup(Monster_Data: MonsterData, new_speed: float = 25.0):
	data = Monster_Data
	animated_sprite.texture = data.texture
	speed = new_speed
	
func despawn():
	queue_free()

func _physics_process(delta):
	if player_chase and player:
		var direction = (player.position - position).normalized()
		position += direction * speed * delta
		move_and_slide()
		#animated_sprite.play("walk_forward")
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		#animated_sprite.play("idle")

func get_encounter_data() -> Array[MonsterData]:
	return [data]
func _on_detection_zone_body_entered(body: Node2D):
	player = body
	player_chase = true 
	
func _on_detection_zone_body_exited(body: Node2D):
	player = null
	player_chase = false

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	emit_signal("battle_triggered")
