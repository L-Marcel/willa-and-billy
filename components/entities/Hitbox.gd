@tool
class_name Hitbox
extends Area2D

@export var character : Character;
var characters : Array[Character] = [];

func hurt() -> void:
	for body in characters:
		body.hurt(character.damage);
func _ready() -> void:
	area_entered.connect(_on_area_entered);
	area_exited.connect(_on_area_exited);
	set_collision_layer_value(1, false);
	set_collision_mask_value(1, true);

func _on_area_entered(area) -> void:
	if area is Hurtbox:
		var body : Node2D = area.get_parent();
		if body != get_parent() && ((body is Player && character is not Player) || (body is Goblin && character is not Goblin)):
			characters.append(body);
func _on_area_exited(area) -> void:
	if area is Hurtbox:
		var body : Node2D = area.get_parent();
		if body in characters: characters.erase(body);
