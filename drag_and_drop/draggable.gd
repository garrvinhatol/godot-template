extends Node2D
class_name Draggable

@onready var state_chart: StateChart = $StateChart as StateChart

@export var docking_node: Node2D
@export var move_position: Vector2
var lerp_speed = 10.0


func _ready():
	g_utils.connect_all_state_signals(self, state_chart)
	g_utils.add_debug_label(self)
	pass

func _on_docking_state_processing(_delta:float):
	var dock_pos = docking_node.position
	if position.distance_to(dock_pos) > 4:
		position = position.lerp(dock_pos, lerp_speed/1.5 * _delta)
	elif position.distance_to(dock_pos) > 3:
		position = position.lerp(dock_pos, (lerp_speed/1.25) * _delta)
	elif position.distance_to(dock_pos) > 2:
		position = position.lerp(dock_pos, (lerp_speed * 3) * _delta)
	else:
		position = dock_pos
		state_chart.send_event("end_dock")
	pass

func _on_moving_state_entered():
	#resets the move position before starting to prevent kicking away.
	move_position = position

func _on_moving_state_processing(_delta:float):
	if position.distance_to(move_position) > 0.05:
		position = position.lerp(move_position, lerp_speed * _delta)
	pass
