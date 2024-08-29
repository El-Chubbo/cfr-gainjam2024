extends Area2D

@export var calorie_amount: int = 0 #increases Cirana's calories by this amount
@export var healing_amount: int = 0 #heals Cirana by this amount
@export var damaging_amount: int = 0 #damages Cirana by this amount
@export var max_health_amount: int = 0 #increases Cirana's max health by this amount
@export var flat_attack_amount: int = 0 #increases or decreases Cirana's base attack by this amount
@export var attack_modifier_amount: float = 0.0 #increases Cirana's damage bonus by this amount
@export var infinite: bool = false #despawns on pickup if false
@export var is_forced: bool = false #will cause calorie overfill if true

func get_stats():
	var stats = {"Calories": calorie_amount, "Health": healing_amount, 
		"Damage": damaging_amount, "MaxHealth": max_health_amount,
		"FlatAttackBoost": flat_attack_amount, "PercentAttackBoost": attack_modifier_amount,
		"Infinite": infinite, "Forced": is_forced}
	return stats

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
