extends ProgressBar

var max_health = 100
var current_health = max_health
@onready var health_text = $Label
signal health_increased(amount)
signal health_decreased(amount)
signal health_changed(current_value)
signal health_depleted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	max_value = max_health
	value = current_health
	update_health()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func set_initial_health(amount: int):
	max_health = amount
	current_health = amount
	update_health()
	return

func update_health():
	var string = str(current_health, "/", max_health)
	health_text.text = string
	max_value = max_health
	value = current_health
	return

func _on_healed_damage(amount: int) -> void:
	if amount >= 1:
		current_health += amount
		if current_health >= max_health:
			current_health = max_health
		update_health()
		health_increased.emit(amount)
		health_changed.emit(current_health)

func _on_took_damage(damage: int) -> void:
	if damage >= 1:
		current_health -= damage
		update_health()
		health_decreased.emit(damage)
		health_changed.emit(current_health)
	if current_health <= 0:
		health_depleted.emit()
		visible = false
