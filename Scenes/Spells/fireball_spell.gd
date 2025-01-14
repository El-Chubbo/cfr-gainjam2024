extends Area2D

signal dealt_damage(damage, victim)

@export var speed = 1250
@onready var impact_SFX = $FireImpactSFX
@export var damage_modifier = 1.0
@onready var trail_particle : Node2D = $FireTrailGPU
@onready var impact_particle : Node2D = $FireImpactGPU
@export var calorie_cost = 150
var base_damage = 0

func _init():
	pass

func _ready() -> void:
	if OS.has_feature("web"):
		#replace particles with their CPU versions, delete GPU nodes
		trail_particle.queue_free()
		impact_particle.queue_free()
		trail_particle = $FireTrailCPU
		impact_particle = $FireImpactCPU
	else:
		$FireTrailCPU.queue_free()
		$FireImpactCPU.queue_free()
	# whether or not it's better to load the correct type on the spot or have both preloaded with the fireball I don't know
	# but the difference should be negligible, as long as there isn't a frame hitch caused by it
	trail_particle.emitting = true
	return

func set_damage(attack: int):
	base_damage += attack

func get_damage():
	return base_damage

func get_cost():
	return calorie_cost

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func complete():
	impact_SFX.play()
	impact_particle.position = self.position #particle doesn't follow the parent for some reason
	impact_particle.emitting = true
	#dealt_damage.emit(base_damage * damage_modifier)
	speed = 0
	$Sprite2D.visible = false
	self.set_deferred("monitoring", false)
	self.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	trail_particle.emitting = false
	await impact_SFX.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void: #collided with wall
	if body.is_in_group("environment"):
		var cell = body.local_to_map($Marker2D.global_position)
		var tile = body.get_cell_tile_data(cell)
		#print_debug("Fireball hit ", tile, " with spell_passthrough data of ", tile.get_custom_data("spell_passthrough"))
		if tile.get_custom_data("spell_passthrough") == true:
			#print_debug("Fireball passed through a tile!")
			return
		complete()
	return

func _on_area_entered(area: Area2D) -> void: #collided with entity
	#to do: behavior for if a monster hits the player with a fireball
	if !area.is_in_group("spell") and !area.is_in_group("pickup"):
		print_debug("Fireball hit ", area, "!")
		dealt_damage.emit(base_damage * damage_modifier, area)
		complete()
	return
