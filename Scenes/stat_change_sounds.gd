extends AudioStreamPlayer

#var calorie_fill_playing = false
var enabled = false

func _on_calories_changed(amount: Variant, difference: int = 0) -> void:
	##I got really confused on the logic here, fuck it
	##random if statements go
	#print_debug("Sound handler received calories changed signal")
	#print_debug("Current calories should be ", amount, " with a difference of ", difference)
	if difference < 0:
		#print_debug("Played no sound for calorie decrease")
		return
	if difference > 0 and PlayerData.current_data["Calories"] <= PlayerData.current_data["MaxCalories"] and enabled:
		#print_debug("Played normal calorie fill")
		self.play(0.0)
		return
	if difference > 0 and PlayerData.current_data["Calories"] > PlayerData.current_data["MaxCalories"] and enabled:
		#sound for overfilling
		#print_debug("Played calorie overfill")
		$CalorieFillAlternate.play()
		return
	if difference == 0 and PlayerData.current_data["Calories"] > PlayerData.current_data["MaxCalories"] and enabled:
		#print_debug("Played 0 calorie gain during overfill")
		$CalorieFillAlternate.play()
		return
	#await get_tree().create_timer(0.8).timeout #hardcoded cut off since the sound file keeps going, should be replaced with a better sound file to not waste space
	#self.stop() #bug: if multiple sounds overlap then the timer stop stops all of them
	##these two issues have been resolved
	return

#func _on_finished() -> void:
	#calorie_fill_playing = false
	#pass # Replace with function body.

func _on_heal_damage(amount: int = 1):
	if PlayerData.current_data["Health"] == PlayerData.current_data["MaxHealth"]:
		$HealMax.play()
	elif amount > 0:
		$Heal.play()
	return

func _on_take_damage(amount: int = 1) -> void:
	if amount <= 0:
		return
	$Hurt.play()
	return

func _on_action_failed(action: Variant) -> void:
	if !DietMode.enabled:
		$TummyGrowl.play()
	return
