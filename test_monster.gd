extends Node2D

@export var initial_health = 100
@onready var health = $"Health Component"
#@onready var stats = $"Monster Stats Component"
@onready var sound = $TargetBreak
signal took_damage()
signal defeated
signal turn_ended(reference)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.set_initial_health(initial_health)
	GameLogic.add_emitter("turn_ended", self)
	GameLogic.add_listener("start_turn", self, "_on_turn_start")
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

#func _on_body_entered(body: Node2D) -> void:
	#wrong signal, moved logic to _on_area_2d_area_entered
	#pass

func _on_turn_start(entity):
	#print_debug(self, " has passed their turn")
	turn_ended.emit(self)
	return

func _on_health_depleted() -> void:
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	sound.play(0.12) #there's a small delay baked into the sound file
	visible = false
	await sound.finished
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print_debug(area.get_groups)
	#print_debug(area.get_meta_list())
	if area.is_in_group("spell") and area.is_in_group("from player"): #check if the body is a spell attack from the player
		var damage_received = area.get_damage()
		took_damage.emit(damage_received)
	return
