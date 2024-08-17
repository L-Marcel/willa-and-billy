@tool
class_name Hurtbox
extends Area2D

@export var health : Health:
	set(value):
		health = value;
		update_configuration_warnings();

func _get_configuration_warnings() -> PackedStringArray:
	var errors : Array[String] = [];
	
	if !health:
		errors.append("Precisa ter um contador de vida!");

	return errors;
