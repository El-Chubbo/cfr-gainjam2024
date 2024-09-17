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
#replace these variables with music_states
enum music_states {FREEMOVE, PLAYER_TURN, ENEMY_TURN}
#this is the second time I've had to make this state, should this be global?
var music_state = music_states.FREEMOVE
var is_paused : bool = false #pause can overlap in functionality so it stays separate
var volume = 1.0
var currently_playing : song_list

var music_bus = AudioServer.get_bus_index("Music")

func _ready() -> void:
	
	GameLogic.add_listener("combat_start", self, "_on_combat_start")
	GameLogic.add_listener("combat_end", self, "_on_combat_end")
	GameLogic.add_listener("player_turn", self, "_on_player_turn")
	GameLogic.add_listener("enemy_turn", self, "_on_enemy_turn")
	##instead of separate listeners, this should probably just be one with an entity reference given and check the node group
	GameLogic.add_listener("paused", self, "_on_game_paused")
	GameLogic.add_listener("unpaused", self, "_on_game_unpaused")
	
	return

func update_state() -> void:
	match music_state:
		music_states.FREEMOVE:
			pass
		music_states.PLAYER_TURN:
			pass
		music_states.ENEMY_TURN:
			pass
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

func default_clips():
	var clip = $Mystic.stream.get_clip_stream(2)
	var clip2 = $Mystic.stream.get_clip_stream(3)
	clip.set_sync_stream_volume(0, 0)
	clip.set_sync_stream_volume(1, 0)
	clip.set_sync_stream_volume(2, 0)
	clip.set_sync_stream_volume(3, -60.0)
	clip2.set_sync_stream_volume(0, 0.0)
	clip2.set_sync_stream_volume(1, 0)
	clip2.set_sync_stream_volume(2, 0)
	clip2.set_sync_stream_volume(3, 0)

func backing_only():
	var clip = $Mystic.stream.get_clip_stream(2)
	var clip2 = $Mystic.stream.get_clip_stream(3)
	clip.set_sync_stream_volume(0, -60.0)
	clip.set_sync_stream_volume(3, -60.0)
	clip2.set_sync_stream_volume(0, -60.0)
	clip2.set_sync_stream_volume(3, -60.0)

func lead_only():
	var clip = $Mystic.stream.get_clip_stream(2)
	var clip2 = $Mystic.stream.get_clip_stream(3)
	clip.set_sync_stream_volume(0, 0)
	clip.set_sync_stream_volume(1, -60.0)
	clip.set_sync_stream_volume(2, -60.0)
	clip.set_sync_stream_volume(3, -60.0)
	clip2.set_sync_stream_volume(0, 0.0)
	clip2.set_sync_stream_volume(1, -60.0)
	clip2.set_sync_stream_volume(2, -60.0)
	clip2.set_sync_stream_volume(3, -60.0)

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
	print_debug("Received pause signal, muffling music")
	AudioServer.set_bus_effect_enabled(1, 0, true)
	AudioServer.set_bus_effect_enabled(1, 1, true)
	AudioServer.set_bus_effect_enabled(1, 2, true)
	AudioServer.set_bus_effect_enabled(1, 3, true)
	return

##in hindsight, maybe both pause and unpause signals should be linked to the same function and simply flip the bool accordingly

func _on_game_unpaused() -> void:
	is_paused = false
	print_debug("Received unpause signal, unmuffling music")
	AudioServer.set_bus_effect_enabled(1, 0, false)
	AudioServer.set_bus_effect_enabled(1, 1, false)
	AudioServer.set_bus_effect_enabled(1, 2, false)
	AudioServer.set_bus_effect_enabled(1, 3, false)
	return

##honestly I should probably ditch using the whole audio stream interactive thing and just script playing audiostreams manually
func audio_transition() -> void:
	match currently_playing:
		song_list.MYSTIC_INTRO:
			#await finished()
			pass
		song_list.MYSTIC_TRANSITION:
			pass
		song_list.MYSTIC_ACT1:
			pass
		song_list.MYSTIC_ACT2:
			pass
		_:
			pass
	return

##I can't find the proper method to call to trigger a transition like "switch to clip" in the editor, try setting auto advances I guess??
func force_play(song: song_list):
	#print_debug("Received force_play signal with input ", song)
	match song:
		song_list.MYSTIC_ACT1:
			if currently_playing == song_list.MYSTIC_INTRO:
				#print_debug("Attempting to switch from Mystic_Intro to Mystic_Transition")
				$Mystic.stream.set_clip_auto_advance(0, 1)
				$Mystic.stream.set_clip_auto_advance_next_clip(0, 1)
				##this area still needs a lot more work
				##I also realize I'm doing crazy logic here instead of update_state()
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
	currently_playing = song
	if currently_playing == song_list.NONE:
		$Mystic.stop()
		$Hyrule.stop()
	return

func _on_finished() -> void:
	#print_debug("Received a finished() signal")
	return
