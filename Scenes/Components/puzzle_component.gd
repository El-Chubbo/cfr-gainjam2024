extends Node2D

signal puzzle_solved(value : bool)

@export var resolvable = false
#if enabled, unsolve() will be called when puzzle conditions are no longer met
#unsolve() is only called when the puzzle is in a solved state
#otherwise the moment all puzzle conditions are met, it remains permanently solved
@export var required_signals : int = 1
@export var puzzle_behaviors : Array[Node]
#scripts for unique puzzle mechanics and results
@export var add_child_behaviors : bool = false
#will search one layer of child nodes to auto add to the behaviors list
#ideally only use one method or the other
@export var inverse_signal : bool = false
enum style {NONE, APPEAR, DISAPPEAR, TOGGLE}
@export var visibility_style = style.NONE
#optional setting to set visibility of the node and its children when solved or unsolved
#none makes nothing occur, appear and dissappear are self explanatory, and toggle flips the current value
var current_value : int = 0
var currently_solved = false

func _ready() -> void:
	if add_child_behaviors:
		#get child nodes in the "puzzle" group and add them to the behaviors
		#as an alternative to manually adding them in the editor
		var children : Array[Node] = get_children()
		for child in children:
			if child.is_in_group("puzzle"):
				puzzle_behaviors.append(child)
	for behavior in puzzle_behaviors:
		#the same naming convention '_on_puzzle_signal_received' is used so
		#multiple puzzle components can connect to each other if necessary
		#like solving 1 puzzle is a prerequisite to another
		puzzle_solved.connect(Callable(behavior, "_on_puzzle_signal_received"))
	return

func solve() -> void:
	print_debug("Puzzle has been solved")
	if puzzle_behaviors.is_empty():
		visible = !visible #default behavior
	currently_solved = true
	if inverse_signal:
		puzzle_solved.emit(false)
	else:
		puzzle_solved.emit(true)
	match visibility_style:
		style.NONE:
			return
		style.APPEAR:
			visible = true
		style.DISAPPEAR:
			visible = false
		style.TOGGLE:
			visible = !visible
	return

func unsolve() -> void:
	print_debug("Puzzle has been unsolved")
	if puzzle_behaviors.is_empty():
		visible = !visible
	currently_solved = false
	if inverse_signal:
		puzzle_solved.emit(true)
	else:
		puzzle_solved.emit(false)
	match visibility_style:
		style.NONE:
			return
		style.APPEAR:
			visible = false
		style.DISAPPEAR:
			visible = true
		style.TOGGLE:
			visible = !visible
	return

func _on_puzzle_signal_received(value: bool):
	print_debug(self, " received puzzle value ", value)
	if value:
		current_value+=1
	else:
		current_value-=1
	print_debug("Puzzle requirements ", current_value, " out of ", required_signals)
	if current_value >= required_signals:
		solve()
	elif currently_solved and resolvable:
		unsolve()
	return
