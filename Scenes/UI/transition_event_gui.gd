extends Control

func play_transition(message : String) -> void:
	%Text.text = message
	$AnimationPlayer.play("phase_transition")
	return

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	visible = false
	return
