extends TileMapLayer
##A puzzle object for door-like tilemap layers
##Ideally I would've wanted to make this more multipurpose, but the exact behavior is reliant on
##the type of node that the class extends

func _ready() -> void:
	
	return

func _on_puzzle_signal_received(value : bool) -> void:
	enabled = value
	return
