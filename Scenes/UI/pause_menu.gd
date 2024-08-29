extends Control

signal unpaused

func reveal(menu: String = "Pause", cause: String = "Unspecified"):
	self.visible = true
	get_tree().paused = true
	if menu == "Pause":
		%GameOverControls.visible = false
		%PauseControls.visible = true
		%ExtraModeControls.visible = false
	if menu == "GameOver":
		update_game_over_text(cause)
		%GameOverControls.visible = true
		%PauseControls.visible = false
		%ExtraModeControls.visible = false
	if menu == "ExtraMode":
		%GameOverControls.visible = false
		%PauseControls.visible = false
		%ExtraModeControls.visible = true
	return

func _resume():
	self.visible = false
	get_tree().paused = false
	unpaused.emit()
	return
	
func _retry():
	var path = get_tree().current_scene.scene_file_path
	GameLogic.goto_scene(path)
	#get_tree().reload_current_scene()
	#get_tree().paused = false
	#unpaused.emit()
	return
	
func _return_to_title():
	GameLogic.goto_scene("res://Scenes/main_menu.tscn")
	return

func _unhandled_input(event: InputEvent) -> void:
	#print_debug("Input event: ", event)
	if event.is_action_pressed("ui_cancel"):
		_resume()
		return

func update_game_over_text(cause: String = "unspecified"):
	%GameOverSubText.text = ("Cirana was knocked out by " + cause + "!\n")
	if cause == "overfill" and !DietMode.enabled:
		%GameOverSubText.text += ("Hopefully she enjoys her food coma...")
		return
	if cause == "extreme overfill" and !DietMode.enabled:
		%GameOverSubText.text += ("Hopefully she doesn't get a tummy ache...")
		return
	%GameOverSubText.text += ("Hopefully she's not too hurt...")
		
