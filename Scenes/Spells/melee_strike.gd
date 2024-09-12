extends Area2D

#this script should handle all melee attacks, regardless of the shape of the melee attack

signal dealt_damage(damage, victim)

enum reactive_properties {DODGEABLE, PARRYABLE, BOTH, NEITHER}
var reactive_property = reactive_properties.BOTH
@export var parameters : Dictionary = {"Startup" : 0.0, "Duration" : 0.0,
				"Cost" : 0, "BaseDamage" : 0, "DamageModifier" : 1.0,}
@export var startup_timer : Timer
@export var duration_timer : Timer

func _ready() -> void:
	startup_timer.wait_time = parameters["Startup"]
	duration_timer.wait_time = parameters["Duration"]
	#a "windup" flash should play warning the attack coming out
	#the color of the flash should indicate what reaction is allowed
	#
	return

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("monster") or (area.is_in_group("player") and !self.is_in_group("from player")):
		dealt_damage.emit(parameters["BaseDamage"] * parameters["DamageModifier"], area)
	return

func get_damage():
	pass
