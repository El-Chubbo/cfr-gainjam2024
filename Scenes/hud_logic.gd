extends CanvasLayer

@export var debug_mode = false
@onready var hearts = $HeartGUI
@onready var turn_label = $TurnStatus
@onready var resource_labels = $ResourceLabels
var player_reference
signal paused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DebugControls.visible = debug_mode
	#var scene = SceneTree.new()
	hearts.setMaxHearts(PlayerData.default_data["MaxHealth"])
	GameLogic.add_listener('game_over', self, '_on_game_over')
	#player_reference = %CiranaPlayer
	#player_reference.health_changed().connect(self._update_health(3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
			_on_pause_button_pressed()
			set_process_unhandled_input(false)

func _update_health(current_health):
	hearts.updateHearts(current_health)
	return

func _set_max_health(amount: int = 1):
	hearts.setMaxHearts(amount)
	hearts.updateHearts(PlayerData.current_data["Health"])
	return

func _update_calories(new_amount: int = 0, _difference: int = 0):
	print_debug("Updating calorie meter to value ", new_amount)
	$CalorieMeter/Label.text = str(new_amount, "/", $CalorieMeter.max_value)
	var tween = get_tree().create_tween()
	tween.tween_property($CalorieMeter, "value", new_amount, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished
	if $CalorieMeter.value > $CalorieMeter.max_value:
		$CalorieMeter/AnimationPlayer.play("flash")
	if $CalorieMeter.value <= $CalorieMeter.max_value:
		$CalorieMeter/AnimationPlayer.stop()
	return

func _update_hotbar():
	pass

func _on_combat_start():
	turn_label.text = "Player turn"
	resource_labels.visible = true

func _on_round_passed(new_entity :Variant):
	if new_entity.is_in_group("monster"):
		turn_label.text = "Enemy turn"
	elif new_entity.is_in_group("player"):
		turn_label.text = "Player turn"
	else: turn_label.text = "idk how you managed to get this text"

func _on_combat_end():
	turn_label.text = "Not in combat"
	resource_labels.visible = false
	pass

func _on_pause_button_pressed() -> void:
	$PauseMenu.reveal("Pause")
	%PauseButton.visible = false

func _on_unpaused() -> void:
	%PauseButton.visible = true
	set_process_unhandled_input(true)

func _on_game_over(cause: String) -> void:
	$PauseMenu.reveal("GameOver", cause)
	%PauseButton.visible = false
