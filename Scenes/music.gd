extends Node

##Each song as two 'acts'
## in and out of combat states
## Cirana turn and non-Cirana turn states (out of combat defaults to Cirana turn)
## pause and un-pause state

##can't decide on interactive-synchronized structure right now
##manually reduce instrument volumes with synchronized? or create presets with interactive?

##new decision, use a muffled audio bus for the pause menu, Act 1 for non-combat, Act 2 for combat, Lead appears for Cirana's turn

enum song_list {NONE, MYSTIC_INTRO, MYSTIC_TRANSITION, MYSTIC_ACT1, MYSTIC_ACT2, HYRULE_ACT1, HYRULE_ACT2}
var in_combat : bool = false
var player_turn : bool = false
var is_paused : bool = false
var volume = 1.0
var currently_playing : song_list

func _ready() -> void:
	
	GameLogic.add_listener("combat_start", self, "_on_combat_start()")
	GameLogic.add_listener("combat_end", self, "_on_combat_end()")
	GameLogic.add_listener("_on_player_turn", self, "_on_player_turn()")
	GameLogic.add_listener("enemy_turn", self, "_on_enemy_turn()")
	GameLogic.add_listener("game_paused", self, "_on_game_paused()")
	GameLogic.add_listener("game_unpaused", self, "_on_game_unpaused()")
	
	
	return

func update_state() -> void:
	match currently_playing:
		song_list.MYSTIC_ACT1:
			#todo: logic for each song act
			pass
		song_list.MYSTIC_ACT2:
			pass
		song_list.HYRULE_ACT1:
			pass
		song_list.HYRULE_ACT2:
			pass
		
	return

func _on_combat_start() -> void:
	in_combat = true
	return

func _on_combat_end() -> void:
	in_combat = false
	return

func _on_player_turn() -> void:
	player_turn = true
	return

func _on_enemy_turn() -> void:
	player_turn = false
	return
	
func _on_game_paused() -> void:
	is_paused = true
	
	return
	
func _on_game_unpaused() -> void:
	is_paused = false
	return

##I can't find the proper method to call to trigger a transition
func force_play(name: song_list):
	print_debug("Received force_play signal with input ", name)
	match name:
		song_list.MYSTIC_ACT1:
			if currently_playing == song_list.MYSTIC_INTRO:
				print_debug("Attempting to switch from Mystic_Intro to Mystic_Transition")
				$Mystic.stream.set_clip_auto_advance(0, 1)
				$Mystic.stream.set_clip_auto_advance_next_clip(0, 1)
				##this area still needs a lot more work
			if currently_playing == song_list.MYSTIC_ACT2:
				
				return
			$Mystic.play()
			$Hyrule.stop()
		song_list.MYSTIC_ACT2:
			$Mystic.play()
			if currently_playing == song_list.MYSTIC_ACT1:
				#$Mystic.set_deferred("parameters/switch_to_clip", "Act2")
				pass
			else:
				#$Mystic.set_deferred("initial_clip", "Act2")
				pass
			$Hyrule.stop()
		_:
			$Mystic.stop()
			$Hyrule.stop()
	currently_playing = name
	if currently_playing == song_list.NONE:
		$Mystic.stop()
		$Hyrule.stop()
	return

func _on_finished() -> void:
	print_debug("Received a finished() signal")
	return
