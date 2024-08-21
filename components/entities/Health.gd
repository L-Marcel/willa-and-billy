class_name Health
extends Node

@export var total : float = 100;
@export var limit : float = 100;

signal death;
signal changed(value : float);
signal damaged;

func hurt(amount : float) -> void:
	if amount <= 0: return;
	damaged.emit();
	total = clamp(total - amount, 0, limit);
	changed.emit(total);
	if total == 0: death.emit();
func heal(amount : float) -> void:
	total = clamp(total + amount, 0, limit);
	changed.emit(total);
