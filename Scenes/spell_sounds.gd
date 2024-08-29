extends AudioStreamPlayer

@onready var fire_hold = $FireHold
@onready var fire_launch = $FireLaunch
var is_casting = false

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_cirana_player_action_casted(input_action: Variant) -> void:
	if input_action == "spell_1":
		play(0.1) #should probably make this script part of a base node instead of an audiostream for better legibility
		is_casting = true
		await get_tree().create_timer(0.15).timeout
		if is_casting:
			fire_hold.play()


func _on_cirana_player_action_canceled() -> void:
	is_casting = false
	fire_hold.stop()


func _on_cirana_player_action_performed(action: Variant) -> void:
	if action == "spell_1":
		#print_debug("Spell launch sound")
		fire_launch.play(0.15)
		fire_hold.stop()
		is_casting = false
