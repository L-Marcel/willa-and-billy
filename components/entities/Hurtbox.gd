@tool
class_name Hurtbox
extends Area2D

func _ready() -> void:
	monitoring = false;
	set_collision_mask_value(1, false);
