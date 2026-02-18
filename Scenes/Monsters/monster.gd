extends CharacterBody2D


const SPEED = 25.0
var player_chase = false
var player = null
signal battle_triggered

func _physics_process(delta):
	if player_chase == true:
		position += (player.position - position)/SPEED
		move_and_slide()

func _on_detection_zone_body_entered(body: Node2D):
	player = body
	player_chase = true 
	
func _on_detection_zone_body_exited(body: Node2D):
	player = null
	player_chase = false

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	emit_signal("battle_triggered")
