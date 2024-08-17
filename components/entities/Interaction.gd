@icon("res://assets/icons/Popup.svg")
class_name Interaction
extends Node

var enabled : bool = true;
var focused : int = 0;

signal action(by : Node);
signal focus;
signal unfocus;

func is_focused() -> bool:
	return focused > 0;

func emit_focus() -> void:
	if focused > 0: focus.emit();
	else: unfocus.emit();
func remove_focus() -> void:
	focused = clamp(focused - 1, 0, 2);
	emit_focus();
func add_focus() -> void:
	focused = clamp(focused + 1, 0, 2);
	emit_focus();

func is_possible() -> bool:
	return action.get_connections().size() == 1 && enabled;
func registry(callable : Callable) -> void:
	for connection in action.get_connections():
		action.disconnect(connection);
	action.connect(callable);
func unregistry() -> void:
	for connection in action.get_connections():
		unfocus.emit();
		action.disconnect(connection["callable"]);
