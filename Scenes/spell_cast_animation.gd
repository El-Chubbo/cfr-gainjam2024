extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_cirana_player_action_casted(input_action: Variant) -> void:
	if input_action == "spell_1":
		play("spell_cast1")
	if input_action == "spell_2":
		play("spell_cast2")
	return

func _on_cirana_player_action_canceled() -> void:
	stop()
	play("default")
	return
