extends Node
class_name ControllerSingleton

@export var drag: GUIDEAction
@export var control_position: GUIDEAction

func _ready() -> void:
	EventBus.controller_singleton = self
	drag.started.connect(start_drag)
	drag.completed.connect(release_drag)
	#sends signals to event bus for inputs
	#sends signal to event bus of objects it detects.
	#event bus will check positions of items
		#draggables update the event_bus when they are ready
	pass

func _process(_delta: float) -> void:
	# EventBus.control_position = control_position.value_axis_2d
	# print(control_position.value_axis_2d)
	pass

func start_drag():
	EventBus.state_chart.send_event("drag")
	# EventBus.clicked_object(get_draggable_at_position(control_position.value_axis_2d))
	# print(get_object_at_position(control_position.value_axis_2d))

func release_drag():
	EventBus.state_chart.send_event("drag_release")
