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
var potatoes : int = 5 :
	set(value):
		potatoes = value;
		resources_changed.emit();
var sprouts : int = 0:
	set(value):
		sprouts = value;
		resources_changed.emit();

func _ready() -> void:
	Game.reset.connect(reset);
	resources_changed.connect(_on_resources_changed);

func reset() -> void:
	willa_health.reset();
	billy_health.reset();
	
func _on_resources_changed() -> void:
	if sprouts == 0 && potatoes == 0:
		Game.game_over("Não há como plantar mais batatas...", 1);
