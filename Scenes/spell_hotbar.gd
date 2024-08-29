extends HBoxContainer

@export var abilities_unlocked = {"Ability1": true, "Ability2": true,
	 "Ability3": true, "Ability4": true}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_visibility()
	#pass # Replace with function body.

func _on_ability_unlocked(ability: String):
	abilities_unlocked[ability] = true
	update_visibility()
	return
	
func update_visibility():
	$AbilityButton.visible = abilities_unlocked["Ability1"]
	$AbilityButton2.visible = abilities_unlocked["Ability2"]
	$AbilityButton3.visible = abilities_unlocked["Ability3"]
	$AbilityButton4.visible = abilities_unlocked["Ability4"]
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

#todo: listener functions for highlighting abilities being availabled, disabled, and gradually becoming unlocked

#todo: functions signaling input events when buttons are pressed

func _on_mouse_entered() -> void:
	#print_debug("Mouse hovered over Hotbar")
	pass # Replace with function body.

func _on_ability1_button_mouse_entered() -> void:
	#print_debug("Mouse hovered over Fireball")
	pass # Replace with function body.

func _on_focus_entered() -> void:
	#print_debug("Hotbar gained focus")
	pass # Replace with function body.

func _on_ability1_button_focus_entered() -> void:
	#print_debug("Fireball gained focus")
	pass # Replace with function body.
