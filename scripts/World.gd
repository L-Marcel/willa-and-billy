@tool
class_name World
extends Node2D

#region Editor
var clock : Clock = Clock.new();
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
	Color.html("#7f708a"),
	Color.html("#9babb2"),
	Color.html("#c7dcd0"),
	Color.html("#ffffff")
];
#endregion

func update_sky_color():
	if day < clock.get_progress_at(0,6):
		sky_color = day_colors[1];
	elif day < clock.get_progress_at(0,9):
		sky_color = day_colors[4];
	elif day < clock.get_progress_at(0,11):
		sky_color = day_colors[5];
	elif day < clock.get_progress_at(0,13):
		sky_color = day_colors[4];
	elif day < clock.get_progress_at(0,15):
		sky_color = day_colors[3];
	elif day < clock.get_progress_at(0, 18):
		sky_color = day_colors[2];
	elif day < clock.get_progress_at(0, 21):
		sky_color = day_colors[1];
	else:
		sky_color = day_colors[0];
	return sky_color;

func _ready():
	if !Engine.is_editor_hint():
		clock = Game.clock;
	update_sky_color();
	canvas_modulate.color = sky_color;
func _process(delta):
	if !Engine.is_editor_hint() || clock_in_editor:
		clock.step(delta * clock_speed);
		day = clock.get_day_progress();
		var current_time = clock.get_time_by_progress(day);
		time = "%s : %s" % [current_time["hours"], current_time["minutes"]];
	elif Engine.is_editor_hint() && !clock_in_editor:
		var current_time = clock.get_time_by_progress(day);
		time = "%s : %s" % [current_time["hours"], current_time["minutes"]];
		clock.reset();
		clock.hours = current_time["hours"];
		clock.minutes = current_time["minutes"];
		clock.step(0);
	stage = clock.stage;
	update_sky_color();
	canvas_modulate.color = lerp(canvas_modulate.color, sky_color, delta);
