extends CharacterBody2D

signal damage_collision(entity)
var tile_size = 256
signal moved
var MOV = 0


@export var animation_speed = 10

#var movement_inputs = {"right": Vector2.RIGHT, 
			#"left": Vector2.LEFT,
			#"up": Vector2.UP,
			#"down": Vector2.DOWN,
			#}
##base_monster script was changed to directly send the direction so this is obsolete

@onready var ray = %RayCast2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("from player") and area.is_in_group("spell"):
		damage_collision.emit(area)
	pass # Replace with function body.

func _on_defeat():
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	return

func _on_receive_movement_request(dir):
	move(dir)
	return

func move(dir) -> bool:
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding() or ray.get_collider().is_in_group("pickup"):
		#position += inputs[dir] * tile_size #instant movement
		moved.emit()
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + dir * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await tween.finished
		return true
	#small tween wiggle for invalid movement
	##this likely won't happen, but good for knowing if pathfinding breaks
	elif ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + dir * (tile_size*0.1), 1.0/animation_speed).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished
		position -= dir * (tile_size*0.1)
		return false
	return false
