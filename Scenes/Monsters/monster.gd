extends CharacterBody2D


const SPEED = 25.0
var player_chase = false
var player = null

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
