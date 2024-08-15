class_name Spot
extends StaticBody2D

@export var interaction : Interaction;
@export var sprite : AnimatedSprite2D;
@export var states : StateMachine;
@export var left : Marker2D;
@export var right : Marker2D;
@export var center : Marker2D;

signal opened;

var clock : Clock = Clock.new();
var potato : Potato;
var progress : float = 0 :
	set(value):
		progress = clamp(value, 0, 1);
		if progress == 1.0:
			opened.emit();
			progress = 0;
			states.send_event("to_opened");

func _ready():
	interaction.registry(use);

func use(by : Node):
	if by is Player && !by.states.get_state() in ["dig", "watering"]:
		match states.get_state():
			"opened":
				if Players.seeds > 0:
					Players.seeds = max(0, Players.seeds - 1);
					states.send_event("to_closed");
					var potato_scene : PackedScene = Scenes.get_resource("Potato");
					potato = potato_scene.instantiate();
					add_child(potato);
					potato.global_position = center.global_position;
			"closed":
				if Players.water > 0:
					Players.water = max(0, Players.water - 1);
					if Game.is_flipped(by): by.water_plants(self, right.global_position);
					else: by.water_plants(self, left.global_position);
			"wet":
				pass;
			_:
				if Game.is_flipped(by): by.dig(self, right.global_position);
				else: by.dig(self, left.global_position);
	elif by is Player:
		by.stop();

func update_sprite():
	var state = states.get_state();
	if state == "wet": sprite.play("wet");
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
func _on_wet_state_entered():
	clock.reset();
	update_sprite();

func _on_wet_state_processing(delta):
	clock.step(delta * Game.clock_speed);
	if clock.hours >= 12:
		states.send_event("to_closed");
		if potato: potato.progress += 0.25;
