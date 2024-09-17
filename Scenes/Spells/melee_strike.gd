extends Area2D

#this script should handle all melee attacks, regardless of the shape of the melee attack
#don't forget when creating new attack scenes utilizing this script to connect the signals

##The Duration parameter is only used when a value other than 0
##When a value is given, the attack will despawn after a fixed amount of time
##If Duration is set to 0, then the animation completing will be used instead

signal dealt_damage(damage, victim)

enum reactive_properties {DODGEABLE, PARRYABLE, BOTH, NEITHER}
@export var reactive_property = reactive_properties.BOTH
@export var rotatable : bool = true #this means the attack is supposed to be rotated with the attack axis
@export var gain_calories : bool = false
@export var parameters : Dictionary = {"Startup" : 0.0, "Duration" : 0.0,
				"Cost" : 0, "BaseDamage" : 0, "DamageModifier" : 1.0, "CalorieModifier" : 0.5}
@export var startup_timer : Timer
@export var duration_timer : Timer


func _ready() -> void:
	#startup_timer.wait_time = parameters["Startup"]
	if parameters["Startup"] == 0.0:
		#No startup means that this is a player attack, therefore the timing is ignored
		return
	startup_timer.wait_time = 0.1 #TEMPORARY UNTIL DEFENSIVE MECHANICS IMPLEMENTED
	duration_timer.wait_time = parameters["Duration"]
	#a "windup" flash should play warning the attack coming out
	#the color of the flash should indicate what reaction is allowed
	#this will be implemented at a later time
	startup_timer.start()
	return

func _on_startup_timeout() -> void:
	if parameters["Duration"] != 0.0:
		duration_timer.start()
	return

func _on_duration_timeout() -> void:
	queue_free()
	return

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if parameters["Duration"] == 0.0:
		queue_free()
	return

func _on_area_entered(area: Area2D) -> void:
	print("Feast attack entered an area")
	if (area.is_in_group("monster") and self.is_in_group("from player")) or (area.is_in_group("player") and !self.is_in_group("from player")):
		dealt_damage.emit(get_damage(), area)
		if gain_calories:
			print_debug("Player should gain ", get_damage() * parameters["CalorieModifier"], " calories")
			PlayerData.reference.add_calories(get_damage() * parameters["CalorieModifier"], true) 
	return

func _on_body_entered(body: Node2D) -> void:
	print("Feast attack entered a body")
	if (body.is_in_group("monster") and self.is_in_group("from player")) or (body.is_in_group("player") and !self.is_in_group("from player")):
		dealt_damage.emit(get_damage(), body)
		if gain_calories:
			print_debug("Player should gain ", get_damage() * parameters["CalorieModifier"], " calories")
			PlayerData.reference.add_calories(get_damage() * parameters["CalorieModifier"], true) 
	return


func get_damage() -> int:
	return parameters["BaseDamage"] * parameters["DamageModifier"]

func set_damage(amount : int = 0):
	parameters["BaseDamage"] = amount
	return
