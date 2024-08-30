extends Area2D

@export var level_destination : PackedScene


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if level_destination.resource_path == "res://Scenes/Levels/thank_you_level.tscn":
			MusicPlayer.lead_only()
		else:
			MusicPlayer.backing_only()
		GameLogic.goto_scene(level_destination.resource_path)
	return
