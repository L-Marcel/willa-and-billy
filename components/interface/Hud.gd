class_name Hud
extends CanvasLayer

@export var willa_bar : Bar;
@export var billy_bar : Bar;
@export var water : Label;

func _ready():
	Players.willa_health.changed.connect(willa_bar.update);
	Players.billy_health.changed.connect(billy_bar.update);
	Players.resources_changed.connect(_on_resources_changed);

func _on_resources_changed():
	water.text = "x" + str(Players.water);
