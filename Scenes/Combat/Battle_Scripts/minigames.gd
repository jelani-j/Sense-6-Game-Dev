extends RefCounted
class_name AttackMinigame

var minigame_container

func clear_minigame_panel():
	for child in minigame_container.get_children():
		child.queue_free()
		
func mini_game_func():
	var minigame_bar = CenterContainer.new()
	minigame_container.add_child(minigame_bar)
	var timing_bar = ProgressBar.new()
	timing_bar.custom_minimum_size = Vector2(300, 20)
	timing_bar.clip_contents = false
	timing_bar.max_value = 100
	minigame_bar.add_child(timing_bar)
	
	var target_spot = ColorRect.new()
	target_spot.color = Color(0.075, 0.918, 0.475, 0.863)
	var target_min = 0.45
	var target_max = 0.55
	setup_target_zone(timing_bar, target_spot, target_min, target_max)
	timing_bar.add_child(target_spot)
	var result = await wait_for_input(timing_bar, target_spot, target_min, target_max)
	#log_container.text += "Minigame_result: " +result
	clear_minigame_panel()
	return result
	
func setup_target_zone(timing_bar, target_spot, target_min, target_max):
	#await get_tree().process_frame
	var bar_width = timing_bar.size.x
	var pixel_min = target_min * bar_width
	var pixel_max = target_max * bar_width
	target_spot.position = Vector2(pixel_min, 0)
	target_spot.size = Vector2(pixel_max - pixel_min, timing_bar.size.y)
	
func wait_for_input(timing_bar, target_spot, target_min, target_max):
	var input_recieved = false 
	var result = "missed"
	var progress = 0.0
	while input_recieved == false:
		#await get_tree().process_frame
		#progress += 1 * get_process_delta_time()
		timing_bar.value = progress * 100
		var time_bar_rect = timing_bar.get_global_rect()
		var target_spot_rect = target_spot.get_global_rect()
		if Input.is_action_just_pressed("minigame_attack"):
			if progress >= target_min and progress <= target_max:
				result = "perfect"
			elif progress >= target_min - 0.1 and progress <= target_max + 0.1:
				result = "good"
			else:
				result = "bad"
			print(result)
			input_recieved = true
	return result
	
func minigame_sequence(action_queue):
	for action in action_queue:
		if not is_instance_valid(action["actor"]) or not action["actor"].is_alive():
			continue
		if action["type"] != "attack":
			continue
		if not (action["actor"].unit_data is PlayerData):
			continue
		var results = await mini_game_func()
		return results
