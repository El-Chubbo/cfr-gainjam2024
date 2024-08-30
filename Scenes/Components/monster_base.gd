extends Node2D

##I'd normally reference an external file to get monster stats, but for the game jam I think it'll be quicker to hardcode
#@export var monster_stats: Resource
@onready var health_component = $"Health Component"
@onready var nav = $NavigationAgent2D

signal finished_turn
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
	GameLogic.add_emitter("finished_turn", self)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_turn_start():
	current_MOV = max_MOV
	current_AP = max_AP

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
	return
