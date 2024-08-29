extends HBoxContainer

@onready var heart_container = preload("res://Scenes/heart_panel.tscn")
var total_hearts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func setMaxHearts(new_max: int):
	print_debug("Increasing max hearts by ", new_max)
	print_debug("Real max value: ", PlayerData.current_data["MaxHealth"])
	for i in range(new_max):
		var heart = heart_container.instantiate()
		total_hearts.append(heart)
		add_child(heart)

func updateHearts(currentHealth: int):
	for i in range(PlayerData.current_data["Health"]):
		total_hearts[i].update(true)
	for i in range(PlayerData.current_data["Health"], total_hearts.size()):
			total_hearts[i].update(false)
	#print_debug("Heart UI updated. ", currentHealth, " current hearts. ", total_hearts.size(), " max.")
