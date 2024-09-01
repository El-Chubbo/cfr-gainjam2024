extends CharacterBody2D

#animations and sounds listen for these signals
signal action_casted(input_action)
signal action_performed(action)
signal action_failed(action)
signal action_canceled
signal ended_turn
signal moved
signal health_changed(new_amount)
signal took_damage(amount)
signal healed_damage(amount)
signal max_health_changed(increase)
signal calories_changed(new_amount: int, difference: int)
signal game_over(cause: String)

var spell_1 = preload("res://Scenes/fireball.tscn")
var spell_2 = preload("res://Scenes/flamethrower.tscn")

var using_preset = true ##temporary variable for using the static gameplay sprites, no dynamic face animations
var weight_level = 0 #used for determining some cosmetic effects, doesn't affect gameplay

#Readied means the player has input a dodge or parry and is waiting for a hitbox collision
#Inactive means no dodge or parry has been input, and the status is off cooldown
#Cooldown means a dodge or parry input failed and cannot be reinput again until the cooldown expires and status returns to inactive
#Dodging means that an attack hitbox was detected while readied and now the player is moving attempting to dodge the attack
#Parrying means that an attack hitbox was detected while readied and now the player is nullifying the attack
enum defensive_states {INACTIVE, READIED, COOLDOWN, DODGING, PARRYING}
var defensive_state = defensive_states.INACTIVE

enum control_states {IDLE, CASTING, MOVING}
var control_state = control_states.IDLE

enum turn_states {FREEMOVE, PLAYER_TURN, ENEMY_TURN}
var turn_state = turn_states.FREEMOVE
##these enums aren't used for now, but should be refactored into the code later


var is_casting = false
var has_turn = true
#var in_combat = false #no limitations on movement and actions while out of combat
##removed to use the global variable instead
var tile_size = 256
@export var override_stats = false ##this is for when stats are enforced for a particular room
@export var max_movement = 3
@export var max_actions = 2
var MOV = max_movement
var AP = max_actions
@export var max_health: int = 3
var current_health = max_health
@export var max_calories = 2000
var current_calories = max_calories
var action_buffer = "none" 
@export var flat_attack_modifier = 0
@export var percentage_attack_modifier = 1.0
@export var base_attack = 100
@export var animation_speed = 6
var moving = false

#this variable is used for calculating how much movement the player has left per turn
#moving back to where they started effectively refunds movement
var old_position = Vector2.ZERO
var new_position = Vector2.ZERO

@onready var ray = $RayCast2D
@onready var casting_animation = $SpellCastAnimation
@onready var spell_sounds = $SpellSounds
@onready var animation = $Sprite2D
#probably redundant variables

var movement_inputs = {"right": Vector2.RIGHT, 
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN,
			}
var action_inputs = {"spell_1": "Fireball",
			"spell_2": "FlameThrower",
			"spell_3": "Explosion",
			"spell_4": "Feast", ##I realized the other day I can probably consolidate Feast into a context-sensitive movement input rather than a cast input
			"spell_5": "Teleport"
			}

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	GameLogic.add_emitter("game_over", self)
	GameLogic.add_emitter("calories_changed", self)
	GameLogic.add_emitter("health_changed", self)
	GameLogic.add_emitter("max_health_changed", self)
	PlayerData.reference = self
	#in hindsight I should've put all the player stats in this script in a dictionary too
	if override_stats:
		PlayerData.current_data["MaxHealth"] = max_health
		PlayerData.current_data["Health"] = current_health
		PlayerData.current_data["MaxCalories"] = max_calories 
		current_calories = 0 #hardcoded for the secret level
		PlayerData.current_data["Calories"] = current_calories 
		PlayerData.current_data["MaxMovement"] = max_movement 
		PlayerData.current_data["MaxActionPoints"] = max_actions 
		PlayerData.current_data["FlatAttackBoost"] = flat_attack_modifier
		PlayerData.current_data["PercentAttackBoost"] = percentage_attack_modifier
	##this is a fucking pain, please be easy to refactor later
	elif GameLogic.saved_data_exists:
		max_health = PlayerData.saved_data["MaxHealth"]
		current_health = PlayerData.saved_data["Health"]
		max_calories = PlayerData.saved_data["MaxCalories"]
		current_calories = PlayerData.saved_data["Calories"]
		max_movement = PlayerData.saved_data["MaxMovement"]
		max_actions = PlayerData.saved_data["MaxActionPoints"]
		flat_attack_modifier = PlayerData.saved_data["FlatAttackBoost"]
		percentage_attack_modifier = PlayerData.saved_data["PercentAttackBoost"]
	else:
		#print_debug("Replacing the current player data: ")
		#print_debug(PlayerData.current_data)
		max_health = PlayerData.default_data["MaxHealth"]
		current_health = PlayerData.default_data["Health"]
		max_calories = PlayerData.default_data["MaxCalories"]
		current_calories = PlayerData.default_data["Calories"]
		max_movement = PlayerData.default_data["MaxMovement"]
		max_actions = PlayerData.default_data["MaxActionPoints"]
		flat_attack_modifier = PlayerData.default_data["FlatAttackBoost"]
		percentage_attack_modifier = PlayerData.default_data["PercentAttackBoost"]
		PlayerData.reset_to_default()
	##big problem here is that I intially began the project using local variables
	##I only introduced global signals later when I realized I needed them
	#health_changed.emit(current_health)
	calories_changed.emit(current_calories, 0)
	print_debug("sent calories changed signal")
	%StatChangeSounds.enabled = true

func _unhandled_input(event):
	if moving:
		return
	#if !has_turn() and GameLogic.:
		#checkParryDodge(event)
		#return
	for dir in movement_inputs.keys():
		if event.is_action_pressed(dir) and !is_casting:
			move(dir)
			return
		elif event.is_action_pressed(dir) and is_casting:
			#print_debug("Received attack input for ", action_buffer, " in ", dir)
			attack(dir)
			return
	for action in action_inputs.keys():
		if event.is_action_pressed(action):
			cast(action)
			return

func move(dir):
	ray.target_position = movement_inputs[dir] * tile_size
	ray.force_raycast_update()
	#print_debug("Raycast is colliding with ", ray.get_collider())
	if !ray.is_colliding() or ray.get_collider().is_in_group("pickup") or ray.get_collider().is_in_group("trigger") or ray.get_collider().is_in_group("spell") and !ray.get_collider().is_in_group("monster") and MOV > 0:
		#position += inputs[dir] * tile_size #instant movement
		moved.emit()
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + movement_inputs[dir] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		moving = true
		await tween.finished
		moving = false
		#calculate MOV difference function
	#small tween wiggle for invalid movement
	elif ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + movement_inputs[dir] * (tile_size*0.1), 1.0/animation_speed).set_trans(Tween.TRANS_ELASTIC)
		moving = true
		await tween.finished
		position -= movement_inputs[dir] * (tile_size*0.1)
		moving = false
	return

#new position is recorded as where the player has moved since the beginning of the turn
#they are only allowed to move a certain amount of spaces away from their origin point, but can move back toward their origin point freely
#elsewhere in the code, if an action is performed, the old position gets updated.
func update_movement_resource(dir: Vector2):
	new_position += dir
	MOV = max_movement - new_position.distance_to(old_position)
	return

#Trigger relevant animations
#Adjust state flags
func cast(action):
	if action == action_buffer: #player input the same spell
		cancel() 
		return
	#print_debug("Began casting action ", action)
	action_buffer = action
	is_casting = true
	action_casted.emit(action_buffer)

func cancel():
	#print_debug("Canceled casting action ", action_buffer)
	action_buffer = "none"
	is_casting = false
	action_canceled.emit()

#perform whatever action is being casted in the specified direction
func attack(dir):
	if action_buffer != "spell_1":
		print_debug("Unfinished spell, ignoring input")
		#temporary statement to prevent crashes
		return
	#print_debug("Launching ", action_buffer, " in the direction ", dir)
	var spell_instance
	#if action_buffer == "spell_1":
		#var b = spell_1.instantiate()
		#owner.add_child(b)
	match action_buffer:
		"spell_1":
			var final_attack: int = base_attack * percentage_attack_modifier + flat_attack_modifier
			if !remove_calories(150): #it's supposed to fetch the spell's cost here, but hardcoding it for now
				#print_debug(spell_1, " spell cast failed. Too few calories!")
				action_failed.emit(action_buffer)
				cancel()
				return
			spell_instance = spell_1.instantiate()
			spell_instance.set_damage(final_attack) #this feels really gross to modify from here, oops coupling
			spell_instance.add_to_group("from player")
			owner.add_child(spell_instance)
		"spell_2":
			pass
		#to do: other spell inputs
		_:
			print_debug("Error, ", action_buffer, " attempted instancing an invalid spell")
	# won't this cause a memory leak of spell_instance declarations for invalid inputs?
	match dir:
		"right":
			spell_instance.transform = $Area2D/MarkerRight.global_transform
		"left":
			spell_instance.transform = $Area2D/MarkerLeft.global_transform
		"up":
			spell_instance.transform = $Area2D/MarkerUp.global_transform
		"down":
			spell_instance.transform = $Area2D/MarkerDown.global_transform
	action_performed.emit(action_buffer)
	cancel()


func teleport(dir) -> bool:
	return false
	#todo

func checkParryDodge(input):
	if defensive_state == defensive_states.INACTIVE:
		#activate parry-dodge state (they share the same states and cooldown)
		#trigger parry or dodge function based on input (directions for dodge or Feast for parry)
		pass
	else: return

func parry() -> void:
	#enable 'parrying' state
	#if an enemy attack is detected that can be eaten during the time frame the parrying state is active,
	#the _on_area_2d_area_entered() script will ignore the damage and will instead add calories
	#after time expires, parrying state is disabled and a cooldown is started
	#
	pass
	
func dodge() -> void:
	#enable 'dodging' state
	#does NOT give invincibility frames
	#if an enemy attack is detected during the time frame the dodging state is active,
	#attempt moving in direction input (dodging towards walls won't work)
	#multi-space attacks should still deal damage if the player doesn't successfully dodge out of it
	pass

func _on_action_performed(action: String = "unspecified"):
	AP -= 1
	old_position = new_position
	if AP <= 0:
		has_turn = false
		ended_turn.emit()
	return

#observer for receiving signal that the player turn has begun
#enable movement, replenish movement and AP to max
#record current tile map position
func _on_turn_begin(entity_ID: Variant):
	if entity_ID.get_rid() == self.get_rid():
		new_position = Vector2.ZERO
		MOV = max_movement
		AP = max_actions
		has_turn = true
	return

#observer for receiving a spell cast input from the player
#Cirana will enter a "charging" state where she waits for a direction input
#Cirana then fires the spell input received in the direction given
func _on_start_cast(action):
	$Area2D/MarkerUp.visible = true
	$Area2D/MarkerRight.visible = true
	$Area2D/MarkerLeft.visible = true
	$Area2D/MarkerDown.visible = true
	return

#If the player inputs the same spell cast hotkey, or chooses a different spell,
#Either cancel the casting animation and return to idle or switch to charging the new spell
func _on_cancel_cast():
	$Area2D/MarkerUp.visible = false
	$Area2D/MarkerRight.visible = false
	$Area2D/MarkerLeft.visible = false
	$Area2D/MarkerDown.visible = false

#func _on_combat_end():
	#in_combat = false
	#pass

#func _on_combat_start():
	#in_combat = true
	#pass

func take_damage(amount: int = 1, type: String = "none"): #default 1 if nothing specified
	if amount == 0:
		return
	current_health -= amount
	print_debug("Cirana took damage from ", type, "!")
	sprite_flicker(0.1)
	if current_health <= 0:
		current_health = 0
		game_over.emit(type)
		has_turn = false
	health_changed.emit(current_health)
	took_damage.emit(amount)
	return

func heal_damage(amount: int):
	if amount > 0:
		current_health += amount
		#print_debug("Healed for ", amount, " heart(s)")
	else:
		healed_damage.emit(amount)
		return
	if current_health > max_health:
		current_health = max_health
		healed_damage.emit(0)
	else:
		sprite_flicker(0.05)
		health_changed.emit(current_health)
		healed_damage.emit(amount)
	return

func add_max_health(amount: int = 1):
	max_health += amount
	PlayerData.current_data["MaxHealth"] = max_health
	max_health_changed.emit(amount)
	return

func sprite_flicker(interval: float = 0.2):
	var flicker_count = 5
	#var timer = get_tree().create_timer(0.1)
	for i in range(flicker_count):
		$Sprite2D.visible = !$Sprite2D.visible
		await get_tree().create_timer(interval).timeout
	#timer.free()
	$Sprite2D.visible = true
	return

#checks for overfill, deals damage if already over 100% calories, double damage if exceeding 150%
#a better solution would've been tying the damage taken to a listener waiting for the calories_changed signal I think
func add_calories(amount: int, forced: bool = false):
	if amount <= 0 or (current_calories > max_calories and !forced):
		calories_changed.emit(current_calories, 0)
		return
	current_calories += amount
	var first_overfill = current_calories - amount <= max_calories
	if current_calories > max_calories:
		if first_overfill: #non-damaging overfill
			if !forced:
				#print_debug()
				current_calories = max_calories #"safe" maxing out calories
			else:
				print_debug("Cirana went over capacity")
				pass
		else:
			if current_calories + amount > max_calories*1.5:
				current_calories = max_calories*1.5
				take_damage(2, "extreme overfill")
			else:
				take_damage(1, "overfill")
	#elif current_calories >= max_calories:
		#if current_calories + amount > max_calories*1.5:
			#current_calories = max_calories*1.5
			#calories_changed.emit(current_calories, amount)
			#take_damage(2, "extreme overfill")
		#else:
			#current_calories += amount
			#calories_changed.emit(current_calories, amount)
			#take_damage(1, "overfill")
	#else:
		#current_calories += amount
		#calories_changed.emit(current_calories, amount)
	calories_changed.emit(current_calories, amount)

#returns true if calorie removal is successful, returns false if cannot remove calories
func remove_calories(amount: int, forced: bool = false):
	if current_calories - amount >= 0 and !forced:
		current_calories -= amount
		calories_changed.emit(current_calories, amount*-1)
		return true
	elif forced:
		current_calories -= amount
		if current_calories < 0:
			current_calories = 0
		calories_changed.emit(current_calories, amount*-1)
		return true
	else:
		return false

func _on_health_changed(amount: int = 1) -> void:
	preset_animation()
	#print_debug("Current health: ", current_health)
	PlayerData.current_data["Health"] = current_health
	if current_health <= 0:	
		#print_debug("Cirana has been knocked out!")
		pass
	return

func preset_animation(): #this should be replaced with an animation mixer in the future for more complex facial expression combinations and saving on texture size
	if !using_preset:
		return
	var stuffed = false
	stuffed = current_calories >= max_calories*0.8
	if weight_level == 0 or DietMode.enabled:
		if current_health <= 1:
			if stuffed and !DietMode.enabled:
				animation.play("stuffed hurt idle")
			else:
				animation.play("hurt idle")
		elif stuffed and !DietMode.enabled:
			animation.play("stuffed idle")
		else:
			animation.play("idle")
	else:
		#todo: more sprites for other weight level
		#if current_health <= 1:
			#if stuffed and !DietMode.enabled:
				#animation.play("fat stuffed hurt idle")
			#else:
				#animation.play("fat hurt idle")
		#elif stuffed and !DietMode.enabled:
			#animation.play("fat stuffed idle")
		#else:
			#animation.play("fat idle")
		return

func get_MOV():
	return MOV

func get_max_health():
	return max_health

func get_AP():
	return AP

#function for walking over pickups or damage zones and taking damage from attacks
func _on_area_2d_area_entered(entity: Area2D) -> void:
	if entity.is_in_group("trigger"):
		return
	if entity.is_in_group("spell") and !entity.is_in_group("from player"):
		take_damage(1, "spell")
		return
	if entity.is_in_group("test") and !entity.is_in_group("from player"):
		add_calories(entity.get_calories(), entity.get_is_forced())
		return
	if entity.is_in_group("pickup") and !entity.is_in_group("test"):
		#add_calories(entity.get_calories(), entity.get_is_forced())
		#perform all possible pickup actions
		var pickup_stats = entity.get_stats()
		if pickup_stats["Calories"] > 0:
			add_calories(pickup_stats["Calories"], pickup_stats["Forced"])
		if pickup_stats["Health"] > 0:
			heal_damage(pickup_stats["Health"])
		take_damage(pickup_stats["Damage"], "pickup")
		add_max_health(pickup_stats["MaxHealth"])
		flat_attack_modifier += pickup_stats["FlatAttackBoost"]
		percentage_attack_modifier += pickup_stats["PercentAttackBoost"]
		return
	return

func _on_calories_changed(new_amount: int, difference: int) -> void:
	preset_animation()
	PlayerData.current_data["Calories"] = current_calories
	return

func get_is_overfilled() -> bool:
	if current_calories > max_calories:
		return true
	return false

##for the game jam, more than two levels of weight won't be supported
func _on_increase_weight():
	weight_level = 1
	return
	
#this is here more for debug reasons, who would want the weight to decrease lmao
func _on_decrease_weight():
	weight_level = 0
	return
