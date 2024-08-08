class_name Spot
extends StaticBody2D

@export var interaction : Interaction;
@export var sprite : AnimatedSprite2D;
@export var states : StateMachine;
@export var left : Marker2D;
@export var right : Marker2D;

var progress : float = 0 :
	set(value):
		progress = clamp(value, 0, 1);

func _ready():
	interaction.registry(use);

func use(by : Node):
	if by is Player:
		match states.get_state():
			"initial":
				states.send_event("to_opening");
				if Game.is_flipped(by): by.dig(self, right.global_position);
				else: by.dig(self, left.global_position);

func update_sprite():
	var state = states.get_state();
	if state == "closed": sprite.play("closed");
	else: sprite.play(state + ("_focused" if interaction.is_focused() else ""));

func _on_interaction_focus():
	update_sprite();
func _on_interaction_unfocus():
	update_sprite();
func _on_inital_state_entered():
	update_sprite();
func _on_opening_state_entered():
	update_sprite();
func _on_opened_state_entered():
	update_sprite();
func _on_closed_state_entered():
	update_sprite();
