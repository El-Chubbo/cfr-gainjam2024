extends Area2D

##this is a quick test script just for adding calories, not to be properly used
##see the resource used for proper pickups

@export var calorie_amount = 300
@export var is_forced = true

func get_calories():
	return calorie_amount

func get_is_forced():
	return is_forced
