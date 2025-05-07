extends Node
class_name ControllerSingleton

@export var drag: GUIDEAction
@export var control_position: GUIDEAction

func _ready() -> void:
	EventBus.controller_singleton = self
	drag.started.connect(start_drag)
	drag.completed.connect(release_drag)
	pass

func start_drag():
	EventBus.state_chart.send_event("drag")


func release_drag():
	EventBus.state_chart.send_event("drag_release")
