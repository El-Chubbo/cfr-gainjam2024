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

func check_attack_in_range(attack: Node2D = null) -> bool:
	#First it checks if the attack is valid in the node group "spell", this is sent by the monster script
	#I need a way of getting the collision property from the attack and copy it to this component
	#Then I need to get what kind of attack is to either do a multi-directional hitbox check,
	#raycast checks, or one large hitbox check for each type respectively
	#Enable the relevant check, if it detects the player node, return true
	
	#ultimately, the monster ONLY attacks if it knows it will be guaranteed to hit
	
	##Ideally I'd like to do this without instancing the spell itself,
	##not only does it save on wastefully loading the spell, but it'd mean I don't have to code despawning it either
	
	#if PlayerData.reference.global_position
	return false
