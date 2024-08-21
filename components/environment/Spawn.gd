class_name Spawn
extends Marker2D

@export var priority : float = 1.0;

func _ready() -> void: Master.add_spawn(self);
