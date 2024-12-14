extends Node2D

@export var resolvable = false
#if enabled, unsolve() will be called when puzzle conditions are no longer met
#unsolve() is only called when the puzzle is in a solved state
@export var required_signals : int = 1
@export var puzzle_behaviors : Array[Node]
#scripts for unique puzzle mechanics and results
var current_value : int = 0
var puzzle_solved = false

func _ready() -> void:
	#todo: configuration with unique puzzle behaviors
	return

func solve() -> void:
	if puzzle_behaviors.is_empty():
		visible = !visible #default behavior, like for doors
		
		puzzle_solved = true
	return

func unsolve() -> void:
	if puzzle_behaviors.is_empty():
		visible = !visible
		puzzle_solved = false
	return

func _on_puzzle_signal_received(value: bool):
	print_debug(self, " received puzzle value ", value)
	if value:
		current_value+=1
	else:
		current_value-=1
	if current_value >= required_signals:
		solve()
	elif puzzle_solved and resolvable:
		unsolve()
	return
