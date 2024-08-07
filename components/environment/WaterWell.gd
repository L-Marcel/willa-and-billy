class_name WaterWell
extends StaticBody2D

@export var sprite : AnimatedSprite2D;
@export var interaction : Interaction;

func _ready():
	interaction.registry(collect);

func collect(by : Node):
	if by is Player && by.states.get_state() != "doing":
		if by.global_position.x != global_position.x:
			by.flip(by.global_position.x > global_position.x);
		by.collect_water();
	elif by is Player:
		by.stop();

func _on_interaction_focus():
	sprite.play("focused");
func _on_interaction_unfocus():
	sprite.play("unfocused");
