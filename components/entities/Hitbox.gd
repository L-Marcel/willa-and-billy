@tool
class_name Hitbox
extends Area2D

@export var character : Character;
@export var disabled : bool = false : 
	set(value):
		disabled = value;
		visible = !disabled;
		if collision:
			collision.disabled = disabled;

var collision : CollisionShape2D :
	set(value):
		collision = value;

func update_collision(_child : Node = null) -> void:
	if has_node("Collision"):
		var _collision : Node = get_node("Collision");
		if _collision is CollisionShape2D:
			_collision.disabled = disabled;
			collision = _collision;

func _ready() -> void:
	update_collision();
	if Engine.is_editor_hint():
		child_entered_tree.connect(update_collision);
		return;
	body_entered.connect(_on_body_entered);

func _on_body_entered(body) -> void:
	if body is Character: 
		if (body is Player && !character is Player) || (!body is Player && character is Player):
			character.health.hurt(body.damage * character.damage_reduction);
