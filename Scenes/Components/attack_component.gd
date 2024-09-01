extends Node2D

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
	
	##Ideally I'd like to do this without instancing the spell itself,
	##not only does it save on wastefully loading the spell, but it'd mean I don't have to code despawning it either
	return false
