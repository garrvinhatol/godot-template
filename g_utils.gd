class_name g_utils
extends Node
#UTILS CODE. Needs to be added as autoload in project settings.
# MUST INHERIT FROM NODE, instanced as a node.

var current_scene = null

# CURRENT SCENE MUST BE SWITCHED IF SCENE SWITCHES HAPPEN
func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)


# Automatically connects state signals for all states in the state chart
# to corresponding methods in the target object
# Parameters:
#   - target: Object - The object that contains the callback methods (usually self)
#   - state_chart: StateChart - The state chart node containing the states
# Returns: void
static func connect_all_state_signals(target: Object, state_chart: StateChart) -> void:
	# Find all states in the state chart
	var states = state_chart.find_children("*", "StateChartState")
	print("Found states: ", states)

	# Connect signals for each state
	for state in states:
		var state_name = state.name.to_snake_case()
		print("Connecting signals for state: ", state.name)

		# List of common state signals to connect
		var signals_to_connect = [
			"state_entered",
			"state_exited",
			"state_processing",
			"state_physics_processing",
			"state_input",
			"state_unhandled_input",
			"state_stepped"
		]

		# Try to connect each signal to the appropriate callback (e.g., "state_entered" -> "_on_idle_state_entered")
		for signal_name in signals_to_connect:
			var method_name = "_on_" + state_name + "_" + signal_name

			# Only connect if the target has the method and the state has the signal
			if target.has_method(method_name) and state.has_signal(signal_name):
				# Check if already connected to avoid duplicate connections
				if !state.is_connected(signal_name, Callable(target, method_name)):
					state.connect(signal_name, Callable(target, method_name))
					print("  Connected: ", signal_name, " -> ", method_name)

# Dictionary to store multiple timers
static var timers = {}

# Creates a new timer with specified parameters
# Parameters:
#   - timer_name: String - Unique identifier for this timer
#   - wait_time: Float - Time in seconds before timeout
#   - target: Object - Object to call the callback method on
#   - callback: String - Method name to call when timeout occurs
#   - autostart: Boolean - Whether to start the timer immediately
#   - one_shot: Boolean - Whether the timer should stop after timeout
#   - parent: Node - Node to add the timer to (required)
# Returns: The created Timer node
static func create_timer(timer_name: String, wait_time: float, target: Object, callback: String,
				  parent: Node, autostart: bool = false, one_shot: bool = true) -> Timer:
	# Check if timer already exists
	if timers.has(timer_name):
		push_warning("Timer with name '" + timer_name + "' already exists. Returning existing timer.")
		return timers[timer_name]

	# Check if parent is valid
	if parent == null:
		push_error("Parent node cannot be null when creating timer.")
		return null

	# Create timer
	var timer = Timer.new()
	timer.name = timer_name
	timer.wait_time = wait_time
	timer.autostart = autostart
	timer.one_shot = one_shot

	# Connect timeout signal if target and callback are valid
	if target != null and target.has_method(callback):
		timer.timeout.connect(Callable(target, callback))
	else:
		push_warning("Target or callback for timer '" + timer_name + "' is invalid.")

	# Add timer to parent
	parent.add_child(timer)
	timers[timer_name] = timer
	return timer

# Starts a previously created timer
# Parameters:
#   - timer_name: String - Name of the timer to start
#   - from_start: Boolean - If true, resets the timer before starting
# Returns: Boolean - True if timer was found and started, false otherwise
static func start_timer(timer_name: String, from_start: bool = true) -> bool:
	if timers.has(timer_name):
		var timer = timers[timer_name]
		if from_start:
			timer.stop() # Reset the timer
		timer.start()
		return true
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Stops a timer
# Parameters:
#   - timer_name: String - Name of the timer to stop
# Returns: Boolean - True if timer was found and stopped, false otherwise
static func stop_timer(timer_name: String) -> bool:
	if timers.has(timer_name):
		timers[timer_name].stop()
		return true
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Gets the time left on a timer
# Parameters:
#   - timer_name: String - Name of the timer to check
# Returns: Float - Time left in seconds, or -1 if timer doesn't exist
static func get_timer_time_left(timer_name: String) -> float:
	if timers.has(timer_name):
		return timers[timer_name].time_left
	push_warning("Timer with name '" + timer_name + "' not found.")
	return -1.0

# Pauses a timer
# Parameters:
#   - timer_name: String - Name of the timer to pause
#   - paused: Boolean - Whether to pause (true) or unpause (false) the timer
# Returns: Boolean - True if timer was found and operation was successful, false otherwise
static func set_timer_paused(timer_name: String, paused: bool = true) -> bool:
	if timers.has(timer_name):
		timers[timer_name].paused = paused
		return true
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Changes the wait time of an existing timer
# Parameters:
#   - timer_name: String - Name of the timer to modify
#   - wait_time: Float - New wait time in seconds
# Returns: Boolean - True if timer was found and modified, false otherwise
static func set_timer_wait_time(timer_name: String, wait_time: float) -> bool:
	if timers.has(timer_name):
		timers[timer_name].wait_time = wait_time
		return true
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Removes a timer completely
# Parameters:
#   - timer_name: String - Name of the timer to remove
# Returns: Boolean - True if timer was found and removed, false otherwise
static func remove_timer(timer_name: String) -> bool:
	if timers.has(timer_name):
		var timer = timers[timer_name]
		timer.stop()
		timer.queue_free()
		timers.erase(timer_name)
		return true
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Checks if a timer exists
# Parameters:
#   - timer_name: String - Name of the timer to check
# Returns: Boolean - True if timer exists, false otherwise
static func has_timer(timer_name: String) -> bool:
	return timers.has(timer_name)

# Checks if a timer is running
# Parameters:
#   - timer_name: String - Name of the timer to check
# Returns: Boolean - True if timer exists and is running, false otherwise
static func is_timer_running(timer_name: String) -> bool:
	if timers.has(timer_name):
		return !timers[timer_name].is_stopped()
	push_warning("Timer with name '" + timer_name + "' not found.")
	return false

# Get all child nodes of specified types without duplicates
# Parameters:
# - parent_node: The parent node to search within
# - node_types: Array of class names as strings (e.g., ["Button", "OptionButton"])
# Returns:
# - Array of nodes that match the specified types, with no duplicates
static func get_nodes_of_types(parent_node, node_types:Array[String]):
	var matching_nodes = []
	# Recursively collect all children in the tree
	var children = _get_all_children(parent_node)

	# Filter nodes by type, avoiding duplicates
	for child in children:
		# Check if child matches any of the requested types
		for node_type in node_types:
			if child.is_class(node_type) and not child in matching_nodes:
				matching_nodes.append(child)
				break # No need to check other types once we've matched

	return matching_nodes

# Helper function to get all children recursively
# Parameters:
# - node: The node to get children from
# Returns:
# - Array of all children nodes in the hierarchy
static func _get_all_children(node):
	var children = []

	for child in node.get_children():
		children.append(child)
		children.append_array(_get_all_children(child))

	return children

# Apply a function to all nodes in the array
# Parameters:
# - nodes: Array of nodes to process
# - callback: Function to call on each node
static func do_to_all_nodes(nodes, callback = null):
	for node in nodes:
		if callback:
			callback.call(node)
		else:
			# Default behavior
			print("Found node: ", node.name, " of type: ", node.get_class())


static func clear_node_input(node):
	# Handle specific node types that should be cleared
	if node.is_class("LineEdit") or node.is_class("TextEdit") or node.is_class("RichTextLabel"):
		node.text = ""
		return true
	elif node.is_class("OptionButton") and node.get("selected"):
		node.selected = 0
		return true
	elif node.is_class("CheckBox") or node.is_class("CheckButton") and node.get("button_pressed"):
		node.button_pressed = false
		return true
	elif (node.is_class("SpinBox") or node.is_class("Slider")) and node.get("value") and node.get("min_value"):
		node.value = node.min_value
		return true
	# If we couldn't or shouldn't clear this node, return false
	return false

# Clear all input fields in a container using the adaptive approach
# Parameters:
# - nodes: Array of nodes to clear
# Returns:
# - void
static func clear_inputs(nodes):
	var cleared_count = 0

	for node in nodes:
		if clear_node_input(node):
			cleared_count += 1

	print("Cleared " + str(cleared_count) + " input fields")

# ADD DEBUG LABEL
static func add_debug_label(node: Node):
	var label = Label.new()
	label.text = node.name
	node.add_child(label)
