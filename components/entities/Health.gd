class_name Health
extends Node

@export var _total : float = 100;
@export var _limit : float = 100;
@export var _base : float = 100;
@export var _invencible : bool = false;
@export var _invencible_duration : float = 1.0;
var _inital_total = _total;
var _inital_limit = _limit;
var _inital_base = _base;
var _inital_invencible = _invencible;

signal death;
signal changed(value : float, limit : float, base : float);
signal damaged;
signal invencibility_tick;
signal invencibility_finished;

func _ready():
	_inital_total = _total;
	_inital_limit = _limit;
	_inital_base = _base;
	_inital_invencible = _invencible;
func reset():
	_total = _inital_total;
	_limit = _inital_limit;
	_base = _inital_base;
	_invencible = _inital_invencible;
	changed.emit(_total, _limit, _base);

func hurt(amount : float):
	if _invencible || amount <= 0:
		return;
	apply_invencibility();
	damaged.emit();
	var limit : float = get_limit();
	_total = clamp(_total - amount, 0, limit);
	changed.emit(_total, limit, _base);
	if _total == 0:
		death.emit();
func heal(amount : float):
	var limit : float = get_limit();
	_total = clamp(_total + amount, 0, limit);
	changed.emit(_total, limit, _base);

func set_total(value : float):
	_total = value;
	changed.emit(_total, get_limit(), _base);
func get_total():
	return min(_total, get_limit());
func get_limit():
	return max(_limit, 0);
func is_dead():
	return get_total() <= 0;

func apply_invencibility():
	_invencible = true;
	var amount : float = 0.0;
	while amount < _invencible_duration:
		invencibility_tick.emit();
		await get_tree().create_timer(0.125).timeout;
		amount += 0.125;
	invencibility_finished.emit();
	_invencible = false;
