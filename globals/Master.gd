extends Node

var _spots : Array[Spot] = [];
var _targets : Array[Spot] = [];
var _spawns : Array[Spawn] = [];

var game_started_now : bool = true;
var attack : bool = false;
var dificult : int = 0;
var amount : int = 0 :
	set(value):
		amount = value;
		if amount == 0 && requested == 0:
			ended.emit();
var requested : int = 0;
var relay : Timer;

signal ended;
signal started(dificult : int);

func _ready() -> void:
	Game.clock.stage_changed.connect(_on_stage_changed);
	relay = Timer.new();
	relay.wait_time = 1;
	relay.timeout.connect(_on_relay_timeout)
	add_child(relay);
	relay.start(1);
	ended.connect(_on_ended);
	started.connect(_on_started);

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

func _on_started(_dificult : int) -> void:
	Game.music.switch_to("Action");
func _on_ended() -> void:
	Game.music.switch_to("Default");
func _on_relay_timeout() -> void:
	relay.start(5 - dificult);
	for _i in range(1, 2 + randi_range(0, min(dificult, 2))):
		if requested > 0:
			requested -= 1;
			if _spawns.size() <= 0: return;
			var priority : float = 0.0;
			for spawn in _spawns:
				priority += spawn.priority;
			priority = randf_range(0.0, priority);
			var target : Vector2 = _spawns[0].global_position;
			for spawn in _spawns:
				priority -= spawn.priority;
				if priority <= 0:
					target = spawn.global_position;
					break;
			var goblin_scene : PackedScene = Scenes.get_resource("Goblin");
			var goblin : Goblin = goblin_scene.instantiate();
			goblin.global_position = target;
			Game.world.add_child(goblin);
func _on_stage_changed(_stage : Clock.DayStage) -> void:
	if game_started_now:
		game_started_now = false;
		return;
	requested = 0;
	var _dificult : float = 0.0;
	if !attack: attack = randf_range(0.0, 1.0) <= 0.8;
	else: 
		_dificult = randf_range(0.0, 0.8);
		attack = randf_range(0.0, 1.0) <= 0.4;
	
	if !attack: return;
	
	if _dificult <= 0.25: dificult = 0;
	elif _dificult <= 0.35: dificult = 1;
	elif _dificult <= 0.75: dificult = 2;
	elif _dificult <= 0.9: dificult = 3;
	else: dificult = 4;
	
	match dificult:
		0, 1: requested = 1 + randi_range(2 + dificult, 4 - (1 - dificult));
		2, 3: requested = 2 + randi_range(2 + dificult, 6 - (3 - dificult));
		_: requested = randi_range(9, 10);
	
	relay.start(randf_range(3.0, 6.0));
	started.emit(dificult);
