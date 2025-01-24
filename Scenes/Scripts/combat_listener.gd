extends Node2D

signal puzzle_triggered(value: bool)
signal combat_event_triggered()

@export var enabled := true
@export var delete_after_action := true
var triggered = false
## Determines what type of signal is listened to, performs action when conditions are met
## QUOTA: A certain amount of enemies defeated, listening for any enemy defeated
## COMBAT: Self explanatory
## SPECIFIC: A specific enemy is defeated
enum listen_types {QUOTA, COMBAT_END, COMBAT_START, SPECIFIC}
## Determines what action is performed when conditions are met
## CUTSCENE: Begins a provided cutscene
## MONSTER: Enables a specific set of monsters and begins combat with them
enum action_types {CUTSCENE, MONSTER, OTHER}
@export var listen_type : listen_types
@export var quota := 1 ## ignored if listen type is anything other than quota
var count := 0
@export var target_monster : Node2D ## for observing this specific monster being defeated, only when listen type is set to specific
@export var action_type : action_types
@export var monster_list : Array[Node2D] ## identical in usage to EventTrigger; activates monsters and adds them to combat
#todo: puzzle signal support like EventTrigger. Or maybe that's super overkill and I'll ignore it idk
@export var dialogue_resource: DialogueResource ## for cutscene events
@export var dialogue_start : String = "start" ## determines where in the dialogue resource a cutscene is read

func _ready() -> void:
	# only create a single relevant listener
	match listen_type:
		0:
			GameLogic.add_listener("defeated", self, "_on_defeat_signal")
		1:
			GameLogic.add_listener("combat_ended", self, "_on_combat_signal")
		2:
			GameLogic.add_listener("combat_started", self, "_on_combat_signal")
		3:
			target_monster.defeated.connect("_on_defeat_signal")
	match action_type:
		0:
			pass
		1:
			pass
		2:
			pass
	return

func enable() -> void:
	enabled = true
	return

func disable() -> void:
	enabled = false
	return

func _on_combat_signal() -> void:
	if not enabled:
		return
	action()
	return

func _on_defeat_signal(enemy: Node2D) -> void:
	if not enabled:
		return
	if listen_type == 0:
		count += 1
		if count >= quota:
			action()
		return
	action() #this should only fire when listen type is set to specific
	return

func action() -> void:
	print_debug("Combat Listener type ", listen_type, " triggered, performing action ", action_type)
	combat_event_triggered.emit()
	match action_type:
		0:
			if !triggered:
				DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
		1:
			if !triggered:
				for monster in monster_list:
					if monster: # check for stale reference
						monster.enable()
					else:
						monster_list.erase(monster)
				GameLogic.combat_start(monster_list)
		2:
			#todo:
			pass
	triggered = true
	if delete_after_action:
		queue_free()
	return
