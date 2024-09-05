extends Node2D

#const PathFindAStar = preload("")
##pathfinding script

##I'd normally reference an external file to get monster stats, but for the game jam I think it'll be quicker to hardcode
#@export var monster_stats: Resource
@onready var health_component = %HealthComponent
@onready var nav = $NavigationAgent2D
@onready var move_component = %MovementComponent
@onready var attack_component = $AttackComponent

var target: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

signal turn_ended(reference)
signal defeated(reference)

@export var max_health = 50
var current_health = max_health
@export var max_MOV = 1
var current_MOV = max_MOV
@export var max_AP = 1
var current_AP = max_AP

var directions = ["up", "down", "left", "right"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set up global signals
	GameLogic.add_emitter("turn_ended", self)
	GameLogic.add_listener("start_turn", self, "_on_turn_start")
	GameLogic.add_emitter("defeated", self)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_turn_start(entity: Variant):
	if entity != self:
		return
	print_debug("Received turn start signal")
	current_MOV = max_MOV
	current_AP = max_AP
	#do more things
	#loop on AP being available, perform attacks if they are in range, end turn if AP = 0
	#if no attacks are in range, follow nav agent path with MOV
	#if it's impossible for the monster to move or there's no MOV left, then end turn
	while (current_AP > 0):
		await get_tree().create_timer(0.5) #small interval between moves so not everything is moving instantly
		##still needs a mean of checking attacks in the monster's movepool
		if attack_component.check_attack_in_range() == true:
			current_AP -= 1
			continue
	#calculate path using navigation Agent
		else:	
			if current_MOV <= 0:
				break
			else:
				var direction = calculate_path()
				print_debug("Attempting to move ", direction)
				var successful_move = await move_component.move(direction)
				if successful_move:	
					current_MOV-= 1
				else: break
				#get the direction of the nearest path stage, then attempt moving that direction
	print_debug("No more valid moves found, ending turn")
	turn_ended.emit(self)
	return

func calculate_path() -> Vector2:
	##the big flaw with the current method is that it doesn't account for ranged monsters
	##ranged monsters should priortize finding an angle that can hit the player, not getting close
	##this interaction may be too complicated to be worth implementing in a project of this scope
	target = PlayerData.reference
	#nav_agent.current_agent_position = global_position
	nav_agent.set_target_position(target.global_position)
	var next_path_position = nav_agent.get_next_path_position()
	#get the nearest direction to take for the path
	##I need to get the vector between the current position and next path position
	##then I need to convert that into a perpendicular direction
	return global_position.direction_to(next_path_position)

func get_MOV():
	return current_MOV

func get_AP():
	return current_AP

func _on_damage_received(entity):
	var amount = entity.get_damage()
	current_health -= amount
	health_component._on_took_damage(amount)
	if current_health <=0:
		defeated.emit(self)
		on_defeat()
		return

func on_defeat():
	#todo: visual effects like vanish shader
	turn_ended.emit(self)
	visible = false
	queue_free()
	return
