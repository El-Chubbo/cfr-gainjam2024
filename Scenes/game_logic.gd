extends Node

#This script handles transitioning scenes, turn management, game states, and persistence between scenes
signal round_passed
signal player_turn
signal enemy_turn
signal combat_starting
signal combat_end
signal start_turn(entity)
signal camera_quick_pan(target: Vector2)

@export var saved_data_exists = false

@export var debug_mode = false

var _emitters = {}
var _listeners = {}
var _emit_queue = []
var _gs_ready = false

var cutscene_active = false
var in_combat = false
var entities = []
var turn_order = []
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
	print_debug("Current level is ", current_level)
	if !player_reference:
		player_reference = get_tree().get_first_node_in_group("player")
	if debug_mode:
		get_tree().debug_collisions_hint = true
		get_tree().debug_navigation_hint = true
		get_tree().debug_paths_hint = true
	game_logic_listeners()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _gs_ready:
		_make_ready()
		set_process(false)
		set_physics_process(false)
	#pass

#this portion is based on code from Josh Anthony
##https://www.joshanthony.info/2021/08/09/creating-a-global-signal-system-in-godot/
#region Global Signal Code
func add_emitter(signal_name: String, emitter: Object) -> void:
	var emitter_data = {'object': emitter, 'object_id': emitter.get_instance_id()}
	if !_emitters.has(signal_name):
		_emitters[signal_name] = {}
	_emitters[signal_name] [emitter.get_instance_id()] = emitter_data
	
	if _listeners.has(signal_name):
		_connect_emitter_to_listeners(signal_name, emitter)

func add_listener(signal_name: String, listener: Object, method: String) -> void:
	var listener_data = {'object': listener, 'object_id': listener.get_instance_id(), 'method':method}
	if !_listeners.has(signal_name):
		_listeners[signal_name] = {}
	_listeners[signal_name][listener.get_instance_id()] = listener_data
	
	if _emitters.has(signal_name):
		_connect_listener_to_emitters(signal_name, listener, method)

func _connect_emitter_to_listeners(signal_name: String, emitter: Object) -> void:
	var listeners = _listeners[signal_name]
	for listener in listeners.values():
		if _process_purge(listener, listeners):
			continue
		emitter.connect(signal_name, Callable(listener.object,listener.method))
	
func _connect_listener_to_emitters(signal_name: String, listener: Object, method: String) -> void:
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

func _on_turn_end():
	print_debug(turn_order[current_turn_index], " turn has ended")
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	start_turn.emit(turn_order[current_turn_index])

##intended turn order examples
#p p m
#p m p m
#p m m p m
#p m m p m m
#p m m m p m m
#p m m m p m m m

#find all entities in the scene, add them to the list, then calculate the turn order
func combat_start():
	if !in_combat:
		print_debug("Initiating combat")
		in_combat = true
		entities = get_tree().get_nodes_in_group("monster")
		turn_order = entities
		turn_order.shuffle()
		turn_order.push_front(player_reference)
		var insertion_point = turn_order.size()/2
		if turn_order.size() % 2 == 1:
			insertion_point += 1
		turn_order.insert(insertion_point,player_reference)
		combat_starting.emit()

func _on_enemy_defeated(enemy: Node2D):
	#remove enemy from turn order and entity list
	print_debug(enemy, "defeated")
	turn_order.erase(enemy)
	entities.erase(enemy)
	camera_quick_pan.emit(enemy.global_position)
	#await camera_reference.quick_pan_completed
	#if there's no enemies left, in_combat = false
	if entities.is_empty():
		in_combat = false
		combat_end.emit()
		print_debug("Combat has ended")
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
	return

func goto_scene(path):
	print_debug("Attempting to load level ", path)
	call_deferred("load_level", path)
	get_tree().paused = false

func _on_game_over():
	#todo: reload save prompt
	return

func game_logic_listeners():
	#add_listener function calls for global listeners
	pass
