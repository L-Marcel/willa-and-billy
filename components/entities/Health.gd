class_name Health
extends Node

@export var _total : float = 100;
@export var _limit : float = 100;
@export var _base : float = 100;
var _inital_total : float = _total;
var _inital_limit : float = _limit;
var _inital_base : float = _base;

signal death;
signal changed(value : float, limit : float, base : float);
signal damaged;

func _ready() -> void:
	_inital_total = _total;
	_inital_limit = _limit;
	_inital_base = _base;
func reset() -> void:
	_total = _inital_total;
	_limit = _inital_limit;
	_base = _inital_base;
	changed.emit(_total, _limit, _base);

func hurt(amount : float) -> void:
	if amount <= 0: return;
	damaged.emit();
	var limit : float = get_limit();
	_total = clamp(_total - amount, 0, limit);
	changed.emit(_total, limit, _base);
	if _total == 0:
		death.emit();
func heal(amount : float) -> void:
	var limit : float = get_limit();
	_total = clamp(_total + amount, 0, limit);
	changed.emit(_total, limit, _base);

func set_total(value : float) -> void:
	_total = value;
	changed.emit(_total, get_limit(), _base);
func get_total() -> float:
	return min(_total, get_limit());
func get_limit() -> float:
	return max(_limit, 0);
func is_dead() -> bool:
	return get_total() <= 0;
