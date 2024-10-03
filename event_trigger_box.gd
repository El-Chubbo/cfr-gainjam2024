extends Area2D

##This script is for events triggered by the player walking into a specified collision shape
##This includes triggering combat, a cutscene, or entities appearing and disappearing such as enemies or locked areas

##since the trigger box shape will vary according to level design, this node has to have a CollisionShape2D or CollisionPolygon2D added as a child manually

enum event_types {COMBAT, CUTSCENE, PUZZLE, OTHER}
@export var event_type : event_types
@export var infinite_trigger = false
var triggered = false
#these handle if the event can only be triggered once or can be repeated
@export var monster_list : Array[Node] 
#this can be specified manually, if left empty it will attempt finding every monster inside the trigger box to build the list
#this way in level design the event trigger boxes can define combat arenas
#when the player enters, the script will broadcast combat start to GameLogic with the predefined list of monsters
@export var locked_door_list : Array[Node]
#behaves similarly to monster_list, can be specified manually or will attempt finding all 'locked' tiles within the triggerbox
@export var unlock_conditions : Dictionary = {}
@export var sequential_trigger : Array[Area2D]
#upon this trigger box being entered, it will enable all other trigger boxes in this list
var collision_box : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#find CollisionShape/Polygon2D child
	#connect signals to trigger_entered
	#check if monster_list and door_list are empty
	#if empty, get list of objects within collision box and add to list accordingly
	#connect relevant signals to said objects
	
	
	pass # Replace with function body.

func sequential_enable() -> void:
	for trigger_box in sequential_trigger:
		trigger_box.enable()
	return

func enable() -> void:
	if collision_box:
		collision_box.set_deferred("Enabled", true)
	return

func _on_trigger_entered(entity : Object) -> void:
	if !triggered or (triggered and infinite_trigger):
		if entity.is_in_group("player"):
			triggered = true
			#todo: more things
			sequential_enable()
			pass
		pass
	pass
