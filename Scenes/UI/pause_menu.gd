extends Control

signal unpaused
signal paused
var game_over = false

func _ready() -> void:
	GameLogic.add_emitter("unpaused", self)
	GameLogic.add_emitter("paused", self)
	return

func reveal(menu: String = "Pause", cause: String = "Unspecified"):
	self.visible = true
	get_tree().paused = true
	paused.emit()
	if menu == "Pause" and !game_over:
		%GameOverControls.visible = false
		%PauseControls.visible = true
		%ExtraModeControls.visible = false
	if menu == "GameOver":
		game_over = true
		update_game_over_text(cause)
		%GameOverControls.visible = true
		%PauseControls.visible = false
		%ExtraModeControls.visible = false
	if menu == "ExtraMode" and !game_over:
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
	if event.is_action_pressed("ui_cancel") and !game_over:
		_resume()
		return

func update_game_over_text(cause: String = "unspecified"):
	%GameOverSubText.text = ("Cirana was knocked out by " + cause + "!\n")
	match cause:
		"overfill":
			%GameOverSubText.text += ("Hopefully she enjoys her food coma...")
		"extreme overfill":
			%GameOverSubText.text += ("Hopefully she doesn't get a tummy ache...")
		"pickup":
			%GameOverSubText.text += ("Hopefully whatever she ate still tasted good...")
		_:
			%GameOverSubText.text += ("Hopefully she's not too hurt...")
	return
