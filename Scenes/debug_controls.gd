extends Control

@onready var combat_button = $EnableCombat
signal force_combat_start
signal force_combat_end
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_enable_combat_pressed() -> void:
	#to do: send signals
	print_debug("Attempting to force combat on")
	GameLogic.combat_start()
	return
