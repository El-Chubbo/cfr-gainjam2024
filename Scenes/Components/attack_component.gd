extends Node2D

##This script is specifically for entities that can perform attacks.
##It does not provide functionality to the logic behind attacks themselves
##For example, seek fireball.tscn, flamethrower.tscn, or short_melee.tscn for the scenes instantiated for attacks

enum Attack_Types {MELEE, RANGED_LOS, RANGED_GLOBAL}
##Ranged Line-of-sight means the attack must pass a line of sight check
##Ranged Global means the attack simply goes off within a set distance of the attack origin
var tile_size = 256

@export var is_parryable = false
@export var is_dodgeable = false

@export var attack_type : Attack_Types

func _ready() -> void:
	
	return

func check_attack_in_range(attacks: Array[PackedScene]) -> bool:
	#First it checks if the attack is valid in the node group "spell", this is sent by the monster script
	#I need a way of getting the collision property from the attack and copy it to this component
	#Then I need to get what kind of attack is to either do a multi-directional hitbox check,
	#raycast checks, or one large hitbox check for each type respectively
	#Enable the relevant check, if it detects the player node, return true
	
	#ultimately, the monster ONLY attacks if it knows it will be guaranteed to hit
	
	##Ideally I'd like to do this without instancing the spell itself,
	##not only does it save on wastefully loading the spell, but it'd mean I don't have to code despawning it either
	
	if PlayerData.reference.global_position.distance_to(self.global_position) < 300:
		var attack_instance = attacks[0].instantiate() #hardcoded choosing the first attack
		#var attack_instance = load("res://Scenes/Spells/short_melee.tscn").
		print(self, " loaded attack resource ", attack_instance)
		#attack_instance.instantiate()
		var parent = owner.get_parent()
		parent.add_child(attack_instance)
		#extremely ineffecient means of getting direction
		var dir : Vector2
		if PlayerData.reference.global_position.x > global_position.x:
			dir = Vector2.RIGHT
		elif PlayerData.reference.global_position.x < global_position.x:
			dir = Vector2.LEFT
		elif PlayerData.reference.global_position.y > global_position.y:
			dir = Vector2.DOWN
		elif PlayerData.reference.global_position.y < global_position.y:
			dir = Vector2.UP
		match dir:
			Vector2.RIGHT:
				attack_instance.transform = $"../Markers/MarkerRight".global_transform
			Vector2.LEFT:
				attack_instance.transform = $"../Markers/MarkerLeft".global_transform
			Vector2.UP:
				attack_instance.transform = $"../Markers/MarkerUp".global_transform
			Vector2.DOWN:
				attack_instance.transform = $"../Markers/MarkerDown".global_transform
		#this is turbo unusuable but I'm trying to get the basics down
		return true
	return false
