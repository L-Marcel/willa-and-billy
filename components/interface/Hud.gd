class_name Hud
extends CanvasLayer

@export var willa_bar : Bar;
@export var billy_bar : Bar;

func _ready():
	Players.willa_health.changed.connect(willa_bar.update);
	Players.billy_health.changed.connect(billy_bar.update);
