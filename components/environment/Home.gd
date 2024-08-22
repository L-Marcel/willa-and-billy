class_name Home
extends StaticBody2D

@export var layers : Array[TileMapLayer] = [];
@export var sound_door : AudioStreamPlayer;
var characters : Array[Character] = [];

func update() -> void:
	var new_visible : bool = characters.size() == 0;
	var old_visible : bool = layers[0].visible;
	if old_visible != new_visible:
		for layer in layers: layer.visible = new_visible;
	sound_door.play();
func _on_zone_body_entered(body) -> void:
	if body is Character:
		characters.append(body);
		update();
func _on_zone_body_exited(body) -> void:
	if body is Character:
		characters.erase(body);
		update();
