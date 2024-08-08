class_name Clock
extends Node

signal stage_changed(to : DayStage);

enum DayStage {
	DAWN,
	MORNING,
	AFTERNOON,
	EVENING,
	NIGHT
};

#region Variables
var stage : DayStage = DayStage.DAWN :
	set(value):
		if stage != value:
			stage = value;
			stage_changed.emit(stage);
var seconds : float = 0;
var minutes : int = 0;
var hours : int = 6;
var days : int = 1;
var years : int = 0;
#endregion

func step(delta : float = 1.0):
	seconds += 60 * delta;
	minutes += int(seconds / 60.0);
	seconds = fmod(seconds, 60.0);
	hours += int(minutes / 60.0);
	minutes = minutes % 60;
	days += int(hours / 24.0);
	hours = hours % 24;
	
	var progress = (hours + minutes/60.0) / 24.0;
	if progress == 0 || progress >= get_progress_at(0, 20):
		stage = DayStage.NIGHT;
	elif progress >= get_progress_at(0, 18):
		stage = DayStage.EVENING;
	elif progress > get_progress_at(0, 12):
		stage = DayStage.AFTERNOON;
	elif progress >= get_progress_at(0, 6):
		stage = DayStage.MORNING;
	else:
		stage = DayStage.DAWN;
	
	years += int(days / 365.0);
	days = days % 365;

#region Getters
func get_day_progress():
	return (hours + minutes/60.0) / 24.0;
func get_progress_at(_minutes : int, _hours : int = 0):
	return (_hours + _minutes/60.0) / 24.0;
func get_time_by_progress(progress : float):
	var _hours : int = floor(24.0 * progress);
	var _minutes : int = floor(60.0 * ((24.0 * progress) - _hours));
	return {
		"hours": _hours,
		"minutes": _minutes
	};
#endregion
#region Other
func has_sun():
	return ![DayStage.EVENING, DayStage.NIGHT].has(stage);
func reset():
	seconds = 0;
	minutes = 0;
	hours = 6;
	days = 0;
	years = 0;
#endregion

func _to_string():
	return "%s : %s : %s : %s : %f " % [years, days, hours, minutes, seconds];
