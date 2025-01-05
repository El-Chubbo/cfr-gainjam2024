extends Area2D

##This script is for events triggered by the player walking into a specified collision shape
##This includes triggering combat, a cutscene, or entities appearing and disappearing such as enemies or locked areas

##since the trigger box shape will vary according to level design, this node has to have a CollisionShape2D or CollisionPolygon2D added as a child manually

signal puzzle_triggered(value: bool)


enum event_types {COMBAT, CUTSCENE, PUZZLE, OTHER}
@export var event_type : event_types
#I really should figure out a means of disabling the relevant export variables depending on event type
@export var initial_value : bool = false
@export var infinite_trigger = false
var triggered = initial_value
#these handle if the event can only be triggered once or can be repeated
@export var toggleable = false
#if enabled, instead of forcing true when the collision box is entered the value is flipped.
#combine with infinite trigger for switches
@export var hold_trigger = false
#if enabled, when the entity leaves the collision box 'triggered' value will flip and be emitted again
@export var inverse_signal = false
#if enabled, the opposite triggered value will be emitted for puzzles
@export var monster_list : Array[Node] 
#this can be specified manually, if left empty it will attempt finding every monster inside the trigger box to build the list
#this way in level design the event trigger boxes can define combat arenas
#when the player enters, the script will broadcast combat start to GameLogic with the predefined list of monsters
@export var puzzle_object_list : Array[Node]
#behaves similarly to monster_list, can be specified manually or will attempt finding all puzzle tiles within the triggerbox
@export var dialogue_resource: DialogueResource ##for cutscene events
@export var dialogue_start : String = "start" ##determines where in the dialogue resource a cutscene is read
#@export var unlock_conditions : Dictionary = {}
#puzzle conditions are being put into a separate script so this likely won't be used

@export var sequential_trigger : Array[Area2D]
#upon this trigger box being entered, it will enable all other trigger boxes in this list
var collision_box : CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_box = $CollisionShape2D ##This could cause problems depending on the node setup in the scene tree
	##for flexibility, this should be changed to accomodate for multiple collision box children and polygon2D
	#check if monster_list and door_list are empty
	#if empty, get list of objects within collision box and add to list accordingly
	#connect relevant signals to said objects
	if monster_list.is_empty():
		#todo: get all monsters within collision box and add them to the list
		pass
	if puzzle_object_list.is_empty():
		#todo: get all puzzle objects within collision box and add them to the list
		pass
		
	for puzzle_object in puzzle_object_list:
		puzzle_triggered.connect(Callable(puzzle_object, "_on_puzzle_signal_received"))
		##this very explicitly can't be global, as multiple puzzles can exist in the same level
	if event_type == event_types.COMBAT:
			GameLogic.add_listener("combat_ended", self, "_on_combat_end")
	return

func sequential_enable() -> void:
	for trigger_box in sequential_trigger:
		trigger_box.enable()
	return

func enable() -> void:
	if collision_box:
		collision_box.set_deferred("Enabled", true)
	return

func _on_trigger_entered(entity : Object) -> void:
	print_debug(entity, " entered an event trigger")
	if !triggered or (triggered and infinite_trigger):
		if entity.is_in_group("player"): #todo: add functionality to check for specific entities rather than only player
			if toggleable:
				triggered = !triggered
			else:
				triggered = true
			match event_type:
				event_types.COMBAT:
					print_debug("Combat event triggered")
					trigger_combat()
				event_types.CUTSCENE:
					trigger_cutscene(entity)
					print_debug("Cutscene event triggered")
				event_types.PUZZLE:
					trigger_puzzle()
					print_debug("Puzzle event triggered")
				event_types.OTHER:
					trigger_other(entity)
					print_debug("Other event triggered")
			sequential_enable()
			collision_box.set_deferred("disabled", !infinite_trigger)
	return

func _on_trigger_exited(entity : Object) -> void:
	print_debug(entity, " left an event trigger")
	if hold_trigger and entity.is_in_group("player"):
		triggered = !triggered
		trigger_puzzle()

#the naming scheme here is different since this is intended for enclosing rooms during battles
#func lock_doors() -> void:
	#for door in puzzle_object_list:
		#door.visible = true
	#return
	#
#func unlock_doors() -> void:
	#for door in puzzle_object_list:
		#door.visible = false
	#return
##deprecated, visibility doesn't remove collision from doors so this doesn't work
##this has been replaced with emitting a positive puzzle signal when combat starts
##and a negative puzzle signal when combat ends


func trigger_combat() -> void:
	if inverse_signal:
		puzzle_triggered.emit(false)
	else:
		puzzle_triggered.emit(true)
	#todo: refactor combat_start logic to support adding one monster at a time
	GameLogic.combat_start(monster_list)
	return
	
func trigger_cutscene(entity : Object) -> void:
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	#todo: enforce game state to lock controls
	#todo: cutscene overlay and additional functionality for other scenarios
	return

func trigger_puzzle() -> void:
	#emits a generic boolean signal that is true or false to all connected puzzle objects
	if !inverse_signal:
		puzzle_triggered.emit(triggered)
	else:
		puzzle_triggered.emit(!triggered)
	return

func trigger_other(entity : Object) -> void:
	#not sure on an 'other' scenario just yet, maybe extra nodes with custom scripts are added as children
	#and this function would traverse the children?
	##this can be used for bespoke one-off interactions, like an environmental damage zone, force feed calories, or camera control
	##doing it this way means Area2D behavior doesn't need to be copy pasted
	return

func _on_combat_end() -> void:
	if triggered and event_type == event_types.COMBAT:
		if inverse_signal:
			print_debug("Combat event trigger emitting true signal")
			puzzle_triggered.emit(true)
		else:
			print_debug("Combat event trigger emitting false signal")
			puzzle_triggered.emit(false)
	return
