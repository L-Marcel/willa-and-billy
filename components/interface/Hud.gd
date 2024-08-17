class_name Hud
extends CanvasLayer

@export var willa_bar : Bar;
@export var billy_bar : Bar;
@export var date : Label;
@export var time : Label;
@export var time_icon : TextureRect;
@export var water : Label;
@export var seeds : Label;
@export var potatoes : Label;

@export var night : Texture;
@export var dawn : Texture;
@export var day : Texture;
@export var evening : Texture;

func _ready() -> void:
	Players.willa_health.changed.connect(willa_bar.update);
	Players.billy_health.changed.connect(billy_bar.update);
	Players.resources_changed.connect(_on_resources_changed);
	Game.clock.stage_changed.connect(_on_stage_changed);
	_on_resources_changed();

func _process(_delta) -> void:
	time.text = "%02d:%02d" % [Game.clock.hours, Game.clock.minutes];
	date.text = "DIA %02d" % [Game.clock.days];

func _on_stage_changed(stage : Clock.DayStage) -> void:
	match stage:
		Clock.DayStage.EVENING:
			time_icon.texture = evening;
		Clock.DayStage.NIGHT:
			time_icon.texture = night;
		Clock.DayStage.DAWN:
			time_icon.texture = dawn;
		_:
			time_icon.texture = day;
func _on_resources_changed() -> void:
	water.text = "x" + str(Players.water);
	seeds.text = "x" + str(Players.seeds);
	potatoes.text = "x" + str(Players.potatoes);
