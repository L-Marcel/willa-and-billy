extends Node

@export var willa_health : Health;
@export var billy_health : Health;
var willa : Player;
var billy : Player;

signal resources_changed;
var water : int = 0 :
	set(value):
		water = value;
		resources_changed.emit();
var seeds : int = 5:
	set(value):
		seeds = value;
		resources_changed.emit();
var potatoes : int = 0 :
	set(value):
		potatoes = value;
		resources_changed.emit();

func _ready():
	Game.reset.connect(reset);

func reset():
	willa_health.reset();
	billy_health.reset();
