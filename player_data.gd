extends Node

#@export var max_movement = 3
#@export var max_actions = 2
#var MOV = max_movement
#var AP = max_actions
#@export var max_health: int = 3
#var current_health = max_health
#@export var max_calories = 2000
#var current_calories = max_calories
#var action_buffer = "none" 
#@export var flat_attack_modifier = 0
#@export var percentage_attack_modifier = 1.0
#@export var base_attack = 100

var default_data = {"Health": 3, "MaxHealth" : 3, "Calories" : 800, "MaxCalories" : 2000,
			"MaxMovement": 3, "MaxActionPoints": 2, "BaseAttack": 100, "FlatAttackBoost": 0, "PercentAttackBoost": 1.0,
			 "Spell1Unlocked" : false, "Spell2Unlocked" : false, "Spell3Unlocked" : false, "Spell4Unlocked" : false,}
#Current MOV and AP aren't necessary to save as only the beginning of rooms are loaded and they get reset per turn anyway
var current_data = default_data.duplicate()
var saved_data = default_data.duplicate()
var saved_level : PackedScene
var reference : Node2D

##important, use functions to update data rather than directly, so that way the script can handle everything else
#future me: I ignored this

func update_saved_data():
	saved_data = current_data
	#todo, saving which level is currently being played
	#saved_level = 
	return

#save data reference: https://youtu.be/43BZsLZheA4?si=Kusl5CURryY9kdtZ
func save_data_to_disk():
	pass

func load_data_from_disk():
	pass

##I really should have the player's stats be a dictionary and be updated through here
func _on_player_stat_updated(stat: String, value):
	current_data[stat] = value
	return

func reset_to_default():
	current_data = default_data.duplicate()
	saved_data = default_data.duplicate()
	return

#todo: listeners to update current_data when player attributes change
