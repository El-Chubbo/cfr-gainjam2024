extends Node2D

#const PathFindAStar = preload("")
##pathfinding script

##I'd normally reference an external file to get monster stats, but for the game jam I think it'll be quicker to hardcode
#@export var monster_stats: Resource
@onready var health_component = %HealthComponent
@onready var nav = $NavigationAgent2D
@onready var move_component = %MovementComponent
#@onready var attack_component

#@export var target: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

signal turn_ended(reference)
signal defeated

@export var max_health = 50
var current_health = max_health
@export var max_MOV = 1
var current_MOV = max_MOV
@export var max_AP = 1
var current_AP = max_AP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set up global signals
	GameLogic.add_emitter("turn_ended", self)
	GameLogic.add_listener("turn_started", self, "_on_turn_start()")
	GameLogic.add_emitter("defeated", self)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_turn_start():
	current_MOV = max_MOV
	current_AP = max_AP
	#do more things
	#check if AP is available, if yes check if player is in range to attack
	if current_AP > 0:
		#if attack_component.attack() == true:
			#AP -= 1
		pass
	else:
		turn_ended.emit(self)
		return
	#if no, attempt following navigation path
	#calculate path using navigation Agent
	
	calculate_path()
	#get the direction of the nearest path stage, then attempt moving that direction
	if move_component.move() == true:
		pass
	else:
		pass
	#end when either AP reaches 0 or there are no valid moves (monster is either stuck or out of MOV)
	turn_ended.emit(self)
	return

func calculate_path():
	
	nav_agent.target_position = PlayerData.reference.global_position
	return

func get_MOV():
	return current_MOV

func get_AP():
	return current_AP

func _on_damage_received(entity):
	var amount = entity.get_damage()
	current_health -= amount
	health_component._on_took_damage(amount)
	if current_health <=0:
		defeated.emit()
		return
	#todo:

func _on_defeat():
	visible = false
	queue_free()
	return
