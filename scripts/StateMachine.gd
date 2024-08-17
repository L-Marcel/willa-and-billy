@icon("state_chart.svg")
@tool

class_name StateMachine
extends StateChart

func _ready() -> void:
	super._ready();

func get_state() -> String:
	if _state is CompoundState:
		if _state._active_state:
			return _state._active_state.name.to_lower();
		else:
			return _state._initial_state.name.to_lower();
	return "undefined";
