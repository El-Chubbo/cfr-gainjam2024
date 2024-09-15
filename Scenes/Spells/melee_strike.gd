extends Area2D

#this script should handle all melee attacks, regardless of the shape of the melee attack

signal dealt_damage(damage, victim)

enum reactive_properties {DODGEABLE, PARRYABLE, BOTH, NEITHER}
@export var reactive_property = reactive_properties.BOTH
@export var rotatable : bool = true #this means the attack is supposed to be rotated with the attack axis
@export var parameters : Dictionary = {"Startup" : 0.0, "Duration" : 0.0,
				"Cost" : 0, "BaseDamage" : 0, "DamageModifier" : 1.0,}
@export var startup_timer : Timer
@export var duration_timer : Timer


func _ready() -> void:
	#startup_timer.wait_time = parameters["Startup"]
	startup_timer.wait_time = 0.1 #TEMPORARY UNTIL DEFENSIVE MECHANICS IMPLEMENTED
	duration_timer.wait_time = parameters["Duration"]
	#a "windup" flash should play warning the attack coming out
	#the color of the flash should indicate what reaction is allowed
	#this will be implemented at a later time
	startup_timer.start()
	return

func _on_startup_timeout() -> void:
	duration_timer.start()
	return

func _on_duration_timeout() -> void:
	queue_free()
	return

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("monster") or (area.is_in_group("player") and !self.is_in_group("from player")):
		dealt_damage.emit(parameters["BaseDamage"] * parameters["DamageModifier"], area)
	return

func get_damage():
	pass
