extends CanvasLayer

@onready var diet_toggle = %DietModeButton
@export var enable_test_levels = false
#@onready var diet_setting = "res://diet_mode.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DietMode.enabled = true
	diet_toggle.set_deferred("button_pressed", DietMode.enabled)
	update_cirana_sprite(DietMode.enabled)
	$MainButtons.visible = true
	$TestLevels.visible = enable_test_levels
	$CreditsControls.visible = false
	#%TitleGraphic.visible = true
	%CiranaArt.visible = true
	MusicPlayer.force_play(MusicPlayer.song_list.MYSTIC_INTRO)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_diet_mode_button_toggled(toggled_on: bool) -> void:
	#print_debug("Diet button has value ", toggled_on)
	DietMode.enabled = toggled_on
	update_cirana_sprite(toggled_on)
	return

func update_cirana_sprite(toggled_on: bool) -> void:
	var current_frame = %CiranaArt.get_frame()
	var current_progress = %CiranaArt.get_frame_progress()
	if toggled_on:
		%CiranaArt.play("idle")
	else:
		%CiranaArt.play("fat idle")
	%CiranaArt.set_frame_and_progress(current_frame, current_progress)
	return

func _on_start_button_pressed() -> void:
	return

##use global GameLogic for loading levels

func _on_credits_button_pressed() -> void:
	$CreditsControls.visible = true
	$MainButtons.visible = false
	$TestLevels.visible = false
	%TitleGraphic.visible = false
	%CiranaArt.visible = false
	$VolumeSliders.visible = true
	return

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	$MainButtons.visible = true
	$TestLevels.visible = enable_test_levels
	$CreditsControls.visible = false
	$HowToPlayControls.visible = false
	#%TitleGraphic.visible = true
	%CiranaArt.visible = true
	$VolumeSliders.visible = true
	return
	
func _on_how_to_play_button_pressed() -> void:
	$HowToPlayControls.visible = true
	$MainButtons.visible = false
	$TestLevels.visible = false
	%TitleGraphic.visible = false
	%CiranaArt.visible = false
	$VolumeSliders.visible = false
	return

func _on_test_button1_pressed() -> void:
	GameLogic.goto_scene("res://Scenes/Levels/test_level.tscn")
	MusicPlayer.force_play(MusicPlayer.song_list.NONE)
	##Music should probably controlled on level load rather than manually from the previous scene
	return

func _on_test_button2_pressed() -> void:
	GameLogic.goto_scene("res://Scenes/Levels/test_level2.tscn")
	MusicPlayer.default_clips()
	MusicPlayer.force_play(MusicPlayer.song_list.MYSTIC_ACT1)
	return
