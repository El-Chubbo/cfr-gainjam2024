extends Resource

#framework for common stats that every monster has

@export var MOV: int #how many spaces the monster can move in a single turn
@export var AP: int #how many actions the monster can perform in a single turn
@export var turn_speed: int #how frequently the monster has a turn ##unused for game jam
@export var health : int
@export var base_attack : int

func _init(p_health = 100, p_base_attack = 1, p_MOV = 0, p_AP = 0, p_turn_speed = 0):
	MOV = p_MOV
	AP = p_AP
	turn_speed = p_turn_speed
	health = p_health
	base_attack = p_base_attack
