extends Control

@onready var combat_button = $EnableCombat
#signal force_combat_start
#signal force_combat_end
#signal combat_start
##this could be implemented with a signal but it seems overkill when I can call the function directly

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameLogic.add_emitter("combat_started", self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_enable_combat_pressed() -> void:
	#to do: send signals
	print_debug("Attempting to force combat on")
	GameLogic.combat_start()
	#combat_start.emit()
	return
