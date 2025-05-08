extends Node
class_name GEventBus

# var draggable_array: Array[Draggable]
var state_chart: StateChart
var dragged_object: Draggable
var controller_singleton: ControllerSingleton
var drag_offset:Vector2 = Vector2.ZERO

func _ready() -> void:
	# Load the state chart scene
	var state_chart_scene = load("res://singletons/game_state_chart.tscn")
	if state_chart_scene:
		# Instance the state chart
		state_chart = state_chart_scene.instantiate()

		if GUtils.current_scene:
			GUtils.current_scene.add_child(state_chart)
			g_utils.connect_all_state_signals(self, state_chart)

func _on_dragging_state_entered():
	var draggable_node = get_draggable_at_position(controller_singleton.control_position.value_axis_2d)
	if draggable_node is Draggable:
		dragged_object = draggable_node
		drag_offset = dragged_object.position - controller_singleton.control_position.value_axis_2d
		if state_chart:
			state_chart.send_event("drag")
		if dragged_object and dragged_object.state_chart:
			dragged_object.state_chart.send_event("move")

func _on_dragging_state_processing(_delta: float):
	if dragged_object:
		dragged_object.move_position =  drag_offset + controller_singleton.control_position.value_axis_2d
# 	pass

func _on_dragging_state_exited():
	var docking_node_candidate = get_drop_area_at_position(controller_singleton.control_position.value_axis_2d)
	if dragged_object and dragged_object.state_chart:
		if docking_node_candidate:
			dragged_object.docking_node =  docking_node_candidate
		dragged_object.state_chart.send_event("start_dock")
		dragged_object = null
	drag_offset = Vector2.ZERO

func get_object_at_position(position):
	# Setup the point query parameters
	var space_state: PhysicsDirectSpaceState2D = GUtils.current_scene.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position

	# Configuration options
	query.collide_with_bodies = true  # Detect physics bodies
	query.collide_with_areas = true   # Detect Area2D nodes too

	# Optional: Set collision mask to filter by layers
	# query.collision_mask = 0b00000010  # Only check layer 2

	# Perform the query
	var result = space_state.intersect_point(query)
	# Return the first object found, or null if nothing was hit
	print(result)
	return result

func get_draggable_at_position(position):
	var objects_at_position = get_object_at_position(position)
	if objects_at_position:
		for results in objects_at_position:
			if results["collider"].owner is Draggable:
				return results["collider"].owner
	return null

func get_drop_area_at_position(position):
	var objects_at_position = get_object_at_position(position)
	if objects_at_position:
		for results in objects_at_position:
			if results["collider"].owner is DropArea:
				return results["collider"].owner
	return null
