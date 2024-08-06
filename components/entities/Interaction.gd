@icon("res://assets/icons/Popup.svg")
class_name Interaction
extends Node

var enabled = true;
var focused = 0;

signal action(by : Node);
signal focus;
signal unfocus;

func is_focused():
	return focused > 0;

func emit_focus():
	if focused > 0: focus.emit();
	else: unfocus.emit();
func remove_focus():
	focused -= 1;
	emit_focus();
func add_focus():
	focused += 1;
	emit_focus();

func is_possible():
	return action.get_connections().size() == 1 && enabled;
func registry(callable : Callable):
	for connection in action.get_connections():
		action.disconnect(connection);
	action.connect(callable);
func unregistry():
	for connection in action.get_connections():
		unfocus.emit();
		action.disconnect(connection["callable"]);
