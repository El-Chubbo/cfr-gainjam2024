extends Area2D

##this is copy-pasted code from the fireball spell
##obviously this should be a spell component or inherited from a superclass, but I didn't do that for fireball
##so shutup >:(

signal dealt_damage(damage, victim)

#@export var speed = 1250
#@onready var fire_impact = $FireImpact
@export var damage_modifier = 1.0
@onready var particle #= $FireImpactParticle
@export var calorie_cost = 600
@export var life_time = 3.0
@onready var timer = $Lifetime
var base_damage = 300
@onready var sprites : Array[Sprite2D] = [$CollisionShape2D/GridContainer/Panel/Sprite2D, $CollisionShape2D/GridContainer/Panel2/Sprite2D,
										$CollisionShape2D/GridContainer/Panel3/Sprite2D, $CollisionShape2D/GridContainer/Panel4/Sprite2D,
										$CollisionShape2D/GridContainer/Panel5/Sprite2D, $CollisionShape2D/GridContainer/Panel6/Sprite2D]
##yeah this array is kinda gross visually but this should be better than doing a wasteful find_children()

#turns out most of the fireball code isn't useful anyway
#the flamethrower behavior is being spawned as a 2x3 cell large hitbox in front of the player
#it gets a list of all enemies that are inside the hitbox and deals damage
#the sprites and particle effects last for a few moments before it despawns
#there's no extra behavior for walls, for now it has the benefit of going through walls
#maybe raycasts could work if it seems too powerful without wall collision? 

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = life_time
	timer.start()
	call_deferred("fix_rotations")
	##this specifically needs to be deferred
	##the global_transform code from the player was overriding the rotation fix so this delays it to the end of the frame
	return

func fix_rotations():
	for sprite in sprites:
		sprite.global_rotation_degrees = 0
		sprite.visible = true
	#print("Rotated flame sprites")
	##this portion of code makes it so the flame sprites always point upward even when the attack gets rotated
	return

func set_damage(attack: int):
	base_damage += attack

func get_damage():
	return base_damage * damage_modifier

func get_cost():
	return calorie_cost

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	#position += transform.x * speed * delta

#func complete():
	#fire_impact.play()
	#particle.position = self.position #particle doesn't follow the parent for some reason
	#particle.emitting = true
	##dealt_damage.emit(base_damage * damage_modifier)
	#speed = 0
	#$Sprite2D.visible = false
	#self.set_deferred("monitoring", false)
	#self.set_deferred("monitorable", false)
	#$FireTrailParticle.emitting = false
	##await fire_impact.finished
	#queue_free()

func _on_body_entered(body: Node2D) -> void: #collided with wall
	#if body.is_in_group("environment"):
		#var cell = body.local_to_map($Marker2D.global_position)
		#var tile = body.get_cell_tile_data(cell)
		#if tile.get_custom_data("spell_passthrough") == true:
			##print_debug("Fireball passed through a tile!")
			#return
		#complete()
	return

func _on_area_entered(area: Area2D) -> void: #collided with entity
	if !area.is_in_group("spell") and !area.is_in_group("pickup"):
		print_debug("Flamethrower hit ", area, "!")
		dealt_damage.emit(base_damage * damage_modifier, area)
		#complete()
	return

func _on_lifetime_timeout() -> void:
	queue_free()
	return
