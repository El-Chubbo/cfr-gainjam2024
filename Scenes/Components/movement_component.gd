extends CharacterBody2D

signal damage_collision(entity)
var tile_size = 256
signal moved
var MOV = 0
@export var parent: Node2D = get_parent()

@export var animation_speed = 10

#var movement_inputs = {"right": Vector2.RIGHT, 
			#"left": Vector2.LEFT,
			#"up": Vector2.UP,
			#"down": Vector2.DOWN,
			#}
##base_monster script was changed to directly send the direction so this is obsolete

@onready var ray = %RayCast2D

func _ready() -> void:
	if !parent:
		parent = get_parent()
	for group in self.get_groups():
		$Area2D/CollisionShape2D.add_to_group(group) # quick way to transfer groups to collision boxes
		$Area2D.add_to_group(group)
	return

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("from player") and area.is_in_group("spell"):
		damage_collision.emit(area)
	pass # Replace with function body.

func _on_defeat(argument):
	disable_collision()
	return

#this can be used for external scripts forcing the entity to move, like a cutscene
func _on_receive_movement_request(entity : Object, dir : Vector2):
	if entity == self:
		move(dir)
	return

func enable_collision() -> void:
	$RootCollision.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	return

func disable_collision() -> void:
	$RootCollision.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	return

func move(dir : Vector2) -> bool:
	#new change, moving the collision detection to its own function
	#this should also be changed in other locations with movement scripts
	dir.normalized()
	var valid_collision = await check_collision(dir)
	print("Valid movement check returned ", valid_collision)
	#the movement component should be abstracted so it can have different rules dependent on which entity has the component
	if valid_collision:
		#position += inputs[dir] * tile_size #instant movement
		moved.emit()
		var tween = create_tween()
		tween.tween_property(parent, "global_position",
			global_position + dir * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		#global_position = global_position.snapped(Vector2.ONE * tile_size)
		#this line was supposed to resolve monsters getting slightly misaligned on movements, but instead broke the positioning completely
		await tween.finished
		return true
	#small tween wiggle for invalid movement
	##this likely won't happen, but good for knowing if pathfinding breaks
	else:
		var tween = create_tween()
		tween.tween_property(parent, "global_position",
			global_position + dir * (tile_size*0.1), 1.0/animation_speed).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished
		parent.global_position -= dir * (tile_size*0.1) #this line was left as simply global_position by accident causing HUGE position desyncs for the longest time holy fuck
		return false
	return false

func check_collision(dir) ->bool:
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding() and dir!= Vector2.ZERO:
		#print_debug("Monster will not collide with an entity, valid move")
		return true
	elif ray.get_collider().is_in_group("monster") or ray.get_collider().is_in_group("player"):
		#print_debug("Monster will collide with entity, invalid move")
		return false
	elif ray.get_collider().is_in_group("pickup") or ray.get_collider().is_in_group("trigger"):
		#print_debug("Monster will collide with non-physical entity, valid move")
		return true
	return false

# manual way to add group to collision box outside of the packed scene
func add_group(name: String) -> void:
	$Area2D/CollisionShape2D.add_to_group(name)
	return
