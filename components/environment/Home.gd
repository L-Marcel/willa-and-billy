class_name Home
extends StaticBody2D

@export var layers : Array[TileMapLayer] = [];
var characters : Array[Character] = [];

func _on_zone_body_entered(body) -> void:
	if body is Character:
		characters.append(body);
		for layer in layers:
			layer.visible = characters.size() == 0;

func _on_zone_body_exited(body) -> void:
	if body is Character:
		characters.erase(body);
		for layer in layers:
			layer.visible = characters.size() == 0;
