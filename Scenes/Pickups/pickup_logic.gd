extends Node2D

@export var is_infinite = false


func _on_pickup_component_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !is_infinite:
		queue_free()
	return
