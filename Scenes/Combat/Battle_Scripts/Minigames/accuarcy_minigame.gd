extends RefCounted
class_name AttackMinigame

func clear_minigame_panel(minigame_container):
	for child in minigame_container.get_children():
		child.queue_free()
		
func mini_game_func(minigame_container):
	#minigame bar 
	var accuracy_container = PanelContainer.new()
	minigame_container.add_child(accuracy_container)
	accuracy_container.custom_minimum_size = Vector2(1000,50)
	accuracy_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER,Control.PRESET_MODE_KEEP_WIDTH)
	
	# OUTER TARGET
	var target_outer = ColorRect.new()
	accuracy_container.add_child(target_outer)
	
	target_outer.color = Color(0.197, 0.579, 0.445, 1.0)
	target_outer.custom_minimum_size = Vector2(100, 50)
	target_outer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	target_outer.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	#moving function for cursor
	var timing_bar = ColorRect.new()
	timing_bar.color = Color(0.937, 0.889, 0.449, 1.0)
	timing_bar.custom_minimum_size = Vector2(5, 50)
	timing_bar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	timing_bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	timing_bar.clip_contents = false
	accuracy_container.add_child(timing_bar)
	var speed = 200.0
	var result = await wait_for_input(timing_bar, speed, target_outer, accuracy_container)
	clear_minigame_panel(minigame_container)
	return result
	
func setup_target_zone(timing_bar, target_spot, target_min, target_max, minigame_container):
	await minigame_container.get_tree().process_frame
	var bar_width = timing_bar.size.x
	var pixel_min = target_min * bar_width
	var pixel_max = target_max * bar_width
	target_spot.position = Vector2(pixel_min, 0)
	target_spot.size = Vector2(pixel_max - pixel_min, timing_bar.size.y)
	
func wait_for_input(timing_bar, speed, target_spot, accuracy_container):
	var input_recieved = false 
	var result = "missed"
	var progress
	while input_recieved == false:
		await accuracy_container.get_tree().process_frame
		timing_bar.position += Vector2.RIGHT * speed * accuracy_container.get_process_delta_time()
		var time_bar_rect = timing_bar.get_global_rect()
		var target_spot_rect = target_spot.get_global_rect()
		if Input.is_action_just_pressed("minigame_attack"):
			if time_bar_rect.intersects(target_spot_rect):
				result = "perfect"
			print(result)
			input_recieved = true
	return result
	
#func minigame_sequence(action_queue):
	#for action in action_queue:
		#if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
			#continue
		#if action["type"] != "attack":
			#continue
		#if not (action["actor"].unit_data is PlayerData):
			#continue
		#var results = await mini_game_func(minigame_container)
		#return results
