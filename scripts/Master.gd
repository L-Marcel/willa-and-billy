extends Node

var _spots : Array[Spot] = [];
var _targets : Array[Spot] = [];
var _spawns : Array[Spawn] = [];

var attack : bool = false;
var dificult : int = 0;

func _ready() -> void:
	Game.clock.stage_changed.connect(_on_stage_changed);

func add_spot(spot : Spot) -> void:
	if spot not in _spots:
		_spots.append(spot);
func remove_spot(spot : Spot) -> void:
	if spot in _spots:
		_spots.erase(spot);
		dismark_spot(spot);
func mark_spot(spot : Spot) -> void:
	if spot not in _targets:
		_targets.append(spot);
func dismark_spot(spot : Spot) -> void:
	if spot in _targets:
		_targets.erase(spot);
func get_nearest_spot(at : Vector2) -> Spot:
	var nearest : Spot = null;
	for spot in _spots:
		if (
			!nearest || spot.global_position.distance_to(at) < nearest.global_position.distance_to(at)
		) && spot not in _targets:
			nearest = spot;
	return nearest;
func add_spawn(spawn : Spawn) -> void:
	_spawns.append(spawn);

func _on_stage_changed(_stage : Clock.DayStage) -> void:
	var _dificult : float = 0.0;
	if !attack: attack = randf_range(0.0, 1.0) <= 0.8;
	else: 
		_dificult = randf_range(0.0, 0.8);
		attack = randf_range(0.0, 1.0) <= 0.4;
	
	if !attack: return;
	
	if _dificult <= 0.45: dificult = 1;
	elif _dificult <= 0.75: dificult = 2;
	elif _dificult <= 0.9: dificult = 3;
	else: dificult = 4;
