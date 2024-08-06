extends Node

@export var willa_health : Health;
@export var billy_health : Health;
var willa : Player;
var billy : Player;

func _ready():
	Game.reset.connect(reset);

func reset():
	willa_health.reset();
	billy_health.reset();
