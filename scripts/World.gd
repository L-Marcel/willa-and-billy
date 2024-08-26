@tool
class_name World
extends Node2D

#region Editor
var clock : Clock = Clock.new(1, 6);
@export var clock_in_editor : bool = false;
@export var clock_speed : float = 1.0;
@export var time : String;
@export var stage : Clock.DayStage;
@export_range(0.0, 1.0) var day : float = 0.0;
@export var sky_color : Color = Color.WHITE;
#endregion

#region Variables
@export_group("Day")
@onready var canvas_modulate : CanvasModulate = %Modulate;
var day_colors = [
	Color.html("#2e222f"),
	Color.html("#694f62"),
	Color.html("#bfbfbf"),
	Color.html("#cccccc"),
	Color.html("#cccccc"),
	Color.html("#ffffff")
];
#endregion

func update_sky_color() -> Color:
	if day < clock.get_progress_at(0,6):
		sky_color = day_colors[1];
	elif day < clock.get_progress_at(0,9):
		sky_color = day_colors[4];
	elif day < clock.get_progress_at(0,13):
		sky_color = day_colors[5];
	elif day < clock.get_progress_at(0,14):
		sky_color = day_colors[4];
	elif day < clock.get_progress_at(0,16):
		sky_color = day_colors[3];
	elif day < clock.get_progress_at(0, 18):
		sky_color = day_colors[2];
	elif day < clock.get_progress_at(0, 21):
		sky_color = day_colors[1];
	else:
		sky_color = day_colors[0];
	return sky_color;

func _ready() -> void:
	randomize();
	if !Engine.is_editor_hint():
		clock = Game.clock;
	update_sky_color();
	canvas_modulate.color = sky_color;
	_setup_world.call_deferred();
func _setup_world():
	if !Game.is_node_ready(): await Game.ready;
	Game.world = self;
func _process(delta) -> void:
	if !Engine.is_editor_hint() || clock_in_editor:
		clock.step(delta * (clock_speed if !Engine.is_editor_hint() else Game.clock_speed));
		day = clock.get_day_progress();
		var current_time : Dictionary = clock.get_time_by_progress(day);
		time = "%s : %s" % [current_time["hours"], current_time["minutes"]];
	elif Engine.is_editor_hint() && !clock_in_editor:
		var current_time : Dictionary = clock.get_time_by_progress(day);
		time = "%s : %s" % [current_time["hours"], current_time["minutes"]];
		clock.reset();
		clock.hours = 6;
		clock.days = 1;
		clock.hours = current_time["hours"];
		clock.minutes = current_time["minutes"];
		clock.step(0);
	stage = clock.stage;
	update_sky_color();
	canvas_modulate.color = lerp(canvas_modulate.color, sky_color, delta);
