extends Node

#This script handles transitioning scenes, turn management, game states, and persistence between scenes
signal round_passed
signal player_turn
signal enemy_turn
#these signals will be used with handling transitions in the turn system
signal combat_started
signal combat_ended
signal start_turn(entity) #emitted to all monsters, if the entity reference matches
signal camera_quick_pan(target: Vector2, type)

@export var saved_data_exists = false

@export var debug_mode = false

enum game_status {CUTSCENE, PLAYERTURN, ENEMYTURN, FREEMOVE, MENU}
var current_game_status = game_status.MENU

var _emitters = {}
var _listeners = {}
var _emit_queue = []
var _gs_ready = false

var cutscene_active = false
var in_combat = false
var entities = []
var turn_order = []
var active_entity : Object
var current_turn_index = 0

var current_level = null

@export var player_reference : CharacterBody2D
@export var quick_diet_mode : bool
#@onready var camera_reference = $"ControllableCamera"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DietMode.enabled = quick_diet_mode
	var root = get_tree().root
	current_level = root.get_child(root.get_child_count() - 1)
	#print_debug("Current level is ", current_level)
	if !player_reference:
		player_reference = get_tree().get_first_node_in_group("player")
	if debug_mode:
		get_tree().debug_collisions_hint = true
		get_tree().debug_navigation_hint = true
		get_tree().debug_paths_hint = true
	game_logic_listeners()
	game_logic_emitters()
	#preload("res://Scenes/fire_trail_particle.tscn")
	#preload("res://Scenes/fire_impact_particle.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _gs_ready:
		_make_ready()
		set_process(false)
		set_physics_process(false)
	#pass

func reset_status() -> void:
	in_combat = false
	current_game_status = game_status.MENU

#function for quickly panning camera on right click
func _unhandled_input(event: InputEvent):
	##I forgot I added a right click to the input map, I should replace this later
	if event == InputEventMouseButton:
		#print_debug("Game Logic received input ", event)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			camera_quick_pan.emit(event.global_position)
		pass
	return

#this portion is based on code from Josh Anthony
##https://www.joshanthony.info/2021/08/09/creating-a-global-signal-system-in-godot/
#region Global Signal Code
func add_emitter(signal_name: String, emitter: Object) -> void:
	#print_debug("Adding signal ", signal_name, " from ", emitter)
	var emitter_data = {'object': emitter, 'object_id': emitter.get_instance_id()}
	if !_emitters.has(signal_name):
		_emitters[signal_name] = {}
	_emitters[signal_name] [emitter.get_instance_id()] = emitter_data
	
	if _listeners.has(signal_name):
		_connect_emitter_to_listeners(signal_name, emitter)

##IMPORTANT, when adding a listener, do not include the () in the method name
func add_listener(signal_name: String, listener: Object, method: String) -> void:
	#print_debug("Adding listener ", signal_name, " from ", listener)
	var listener_data = {'object': listener, 'object_id': listener.get_instance_id(), 'method':method}
	if !_listeners.has(signal_name):
		_listeners[signal_name] = {}
	_listeners[signal_name][listener.get_instance_id()] = listener_data
	
	if _emitters.has(signal_name):
		_connect_listener_to_emitters(signal_name, listener, method)

func _connect_emitter_to_listeners(signal_name: String, emitter: Object) -> void:
	#print_debug("Successfully connected emitter ", emitter, " to ", signal_name)
	var listeners = _listeners[signal_name]
	for listener in listeners.values():
		if _process_purge(listener, listeners):
			continue
		emitter.connect(signal_name, Callable(listener.object,listener.method))
	
func _connect_listener_to_emitters(signal_name: String, listener: Object, method: String) -> void:
	#print_debug("Successfully connected emitter ", listener, " to ", signal_name)
	var emitters = _emitters[signal_name]
	for emitter in emitters.values():
		if _process_purge(emitter, emitters):
			continue
		emitter.object.connect(signal_name, Callable(listener,method))
	#if _emitters.has(signal_name):
		#_connect_listener_to_emitters(signal_name, listener, method)
	##Godot 4 implementation
		
func remove_emitter(signal_name: String, emitter: Object) -> void:
	if !_emitters.has(signal_name):
		return
	if !_emitters[signal_name].has(emitter.get_instance_id()):
		return
	
	_emitters[signal_name].erase(emitter.get_instance_id())
	
	if _listeners.has(signal_name):
		for listener in _listeners[signal_name].values():
			if _process_purge(listener, _listeners[signal_name]):
				continue
			if emitter.is_connected(signal_name, Callable(listener.object,listener.method)): #edited for Godot 4
				emitter.disconnect(signal_name, Callable(listener.object,listener.method)) 

func remove_listener(signal_name: String, listener: Object, method: String) -> void:
	if !_listeners.has(signal_name):
		return
	if !_listeners[signal_name].has(listener.get_instance_id()):
		return
	
	_listeners[signal_name].erase(listener.get_instance_id())
	
	if _emitters.has(signal_name):
		for emitter in _emitters[signal_name].values():
			if _process_purge(emitter, _emitters[signal_name]):
				continue
			if emitter.object.is_connected(signal_name,Callable(listener,method)):
				emitter.object.disconnect(signal_name,Callable(listener,method))

func _process_purge(data: Dictionary, group: Dictionary) -> bool:
	var object_exists = !!weakref(data.object).get_ref() and is_instance_valid(data.object)
	
	if !object_exists or (data.object.get_instance_id() != data.object_id):
		group.erase(data.object_id)
		return true
	return false

func _make_ready() -> void:
	_gs_ready = true
	_process_emit_queue()
	
func _process_emit_queue() -> void:
	for emitted_signal in _emit_queue:
		emitted_signal.args.push_front(emitted_signal.signal_name)
		emitted_signal.emitter.callv('emit_signal', emitted_signal.args)
	_emit_queue = []

func emit_signal_when_ready(signal_name: String, args: Array, emitter: Object) -> void:
	if not _emitters.has(signal_name):
		push_error('GlobalSignal.emit_signal_when_ready: Signal is not registered with GlobalSignal (', signal_name, ').')
		return
		
	if not _gs_ready:
		_emit_queue.push_back({ 'signal_name': signal_name, 'args': args, 'emitter': emitter })
	else:
		args.push_front(signal_name)
		emitter.callv('emit_signal', args)

##in hindsight I should've probably made this its own dedicated script instead of being in game logic
#endregion

func _on_turn_end(entity: Object):
	if in_combat:
		print_debug("Received end turn signal from ", entity)
		if turn_order[current_turn_index] == entity:
			print_debug(turn_order[current_turn_index], " turn has ended")
			current_turn_index += 1
			if current_turn_index >= turn_order.size():
				current_turn_index = 0
			round_passed.emit()
		else:
			print_debug("Turn end signal from ", entity, " does not match turn index for ", turn_order[current_turn_index])
			return
	return

func _on_turn_start():
	##this has probably become obsolete with transition handler existing
	
	
	return

##intended turn order examples
#p p m
#p m p m
#p m m p m
#p m m p m m
#p m m m p m m
#p m m m p m m m
##this isn't balanced very well for high amounts of monsters until the parry/dodge system is implemented
##a better solution would be a speed stat so the player could have a regular interval of turns, Honkai Star Rail for example
##the complexity may be too high for a project of this scale however, encounters could be kept to just a handful of monsters

#find all entities in the scene, add them to the list, then calculate the turn order
func combat_start():
	if !in_combat:
		in_combat = true
		print_debug("Setting combat to", in_combat)
		entities = get_tree().get_nodes_in_group("monster")
		turn_order = entities.duplicate()
		turn_order.shuffle()
		turn_order.push_front(player_reference)
		var insertion_point = turn_order.size()/2
		if turn_order.size() % 2 == 1:
			insertion_point += 1
		turn_order.insert(insertion_point,player_reference)
		print_debug("Monsters listed: ", entities)
		print_debug("Turn order generated: ", turn_order)
		combat_started.emit()
		combat_loop()

func combat_loop() ->void:
	while(in_combat):
		#a transition function should be included here for better separation between turns
		active_entity = turn_order[current_turn_index]
		await transition_handler()
		start_turn.emit(turn_order[current_turn_index])
		print("Turn active for ", turn_order[current_turn_index])
		#signal logic and checks for whose turn it is
		#sending signals to whichever entity has the turn
		#waits until the entity emits its "turn_ended" signal
		await round_passed
		#synchronization issue: monsters move instantly upon player turn ending when it should wait until after spells finish
		#if a fireball kills a monster "mid-turn," it never emits its end turn signal and the game softlocks
		#await get_tree().create_timer(2.0).timeout ##removed because transition handler does the pauses now
	return

func _on_enemy_defeated(enemy: Node2D):
	#remove enemy from turn order and entity list
	if !in_combat:
		return
	print_debug(enemy, "defeated")
	if enemy == active_entity:
		current_turn_index -= 1
		round_passed.emit()
		#game softlocks without the round_passed.emit()
	elif current_turn_index > turn_order.find(enemy):
		current_turn_index -= 1
	turn_order.erase(enemy)
	entities.erase(enemy)
	print_debug("Turn order is now ", turn_order)
	#the quick pans keep going to strange positions
	camera_quick_pan.emit(enemy.global_position)
	await get_tree().create_timer(1.0).timeout
	camera_quick_pan.emit(player_reference.global_position)
	#await camera_reference.quick_pan_completed
	#if there's no enemies left, in_combat = false
	if entities.is_empty():
		in_combat = false
		turn_order.clear()
		combat_ended.emit()
		print_debug("Combat has ended")
	return

##this function will handle pauses in the turn system and signal when a player or enemy turn starts
##the intent is that a pause only occurs when transitioning between the two types of turn
##player or enemy turns back-to-back won't have a pause
func transition_handler() -> void:
	if(active_entity.is_in_group("player")):
		player_turn.emit()
		if current_game_status != game_status.PLAYERTURN:
			await get_tree().create_timer(1.0).timeout
		current_game_status = game_status.PLAYERTURN
	elif(active_entity.is_in_group("monster")):
		if current_game_status != game_status.ENEMYTURN:
			enemy_turn.emit()
			await get_tree().create_timer(1.0).timeout
		current_game_status = game_status.ENEMYTURN
	return

#func _on_property_list_changed() -> void:
	#if in_combat == true:
		#combat_start()
	#return

func _on_level_cleared():
	#todo: save data
	return

func load_save_game():
	#load PlayerData.saved_level
	#load PlayerData.saved_data into current_data
	pass

func load_level(path):
	current_level.free()
	
	var s = ResourceLoader.load(path)
	
	current_level = s.instantiate()
	get_tree().root.add_child(current_level)
	get_tree().current_scene = current_level
	player_reference = get_tree().get_first_node_in_group("player")
	return

func load_level_status(path):
	##This is a terrible way of enforcing game state on level load
	##but I'm not sure about the alternative?
	##I don't want every level to require it's own script just so it can change the state on load
	##It could be an exportable variable like "state on level load" but the effect is basically the same?
	##only difference being where to actually set it
	match path:
		"res://Scenes/test_level.tscn":
			current_game_status = game_status.FREEMOVE
		"res://Scenes/test_level2.tscn":
			current_game_status = game_status.FREEMOVE
		"res://Scenes/main_menu.tscn":
			current_game_status = game_status.MENU
	in_combat = false
	turn_order.clear()
	entities.clear()

func goto_scene(path):
	print_debug("Attempting to load level ", path)
	call_deferred("load_level", path)
	load_level_status(path)
	get_tree().paused = false

func _on_game_over():
	#todo: reload save prompt
	return

func game_logic_listeners():
	#add_listener function calls for global listeners
	add_listener("turn_ended", self, "_on_turn_end")
	add_listener("level_cleared", self, "_on_level_cleared")
	add_listener("defeated", self, "_on_enemy_defeated")
	return

func game_logic_emitters():
	#add_emitters function calls for global emitters
	add_emitter("player_turn", self)
	add_emitter("enemy_turn", self)
	add_emitter("combat_started", self)
	add_emitter("combat_ended", self)
	add_emitter("start_turn", self)
	add_emitter("camera_quick_pan", self)
	return
