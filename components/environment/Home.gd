class_name Home
extends StaticBody2D

@export var ceils : Array[TileMapLayer] = [];
var characters : Array[Character] = [];

func _on_zone_body_entered(body):
	if body is Character:
		characters.append(body);
		for ceil in ceils:
			ceil.visible = characters.size() == 0;

func _on_zone_body_exited(body):
	if body is Character:
		characters.erase(body);
		for ceil in ceils:
			ceil.visible = characters.size() == 0;
