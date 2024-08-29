extends Area2D

signal dealt_damage(damage, victim)

@export var speed = 1250
@onready var fire_impact = $FireImpact
@export var damage_modifier = 1.0
@onready var particle = $FireImpactParticle
@export var calorie_cost = 150
var base_damage = 0

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
	fire_impact.play()
	particle.position = self.position #particle doesn't follow the parent for some reason
	particle.emitting = true
	#dealt_damage.emit(base_damage * damage_modifier)
	speed = 0
	$Sprite2D.visible = false
	self.set_deferred("monitoring", false)
	self.set_deferred("monitorable", false)
	$FireTrailParticle.emitting = false
	await fire_impact.finished
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
		#print_debug("Fireball hit ", area, "!")
		dealt_damage.emit(base_damage * damage_modifier, area)
		complete()
	return
