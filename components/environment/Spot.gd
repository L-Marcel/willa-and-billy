class_name Spot
extends StaticBody2D

@export var interaction : Interaction;
@export var sprite : AnimatedSprite2D;
@export var states : StateMachine;
@export var left : Marker2D;
@export var right : Marker2D;
@export var center : Marker2D;
@export var initial_grow_level : float = 0.0;
signal opened;

var clock : Clock = Clock.new();
var potato : Potato :
	set(value):
		potato = value;
		if potato: Master.add_spot(self);
		else: Master.remove_spot(self);
var progress : float = 0 :
	set(value):
		progress = clamp(value, 0, 1);
		if progress == 1.0:
			opened.emit();
			for connection in opened.get_connections():
				opened.disconnect(connection["callable"]);
			progress = 0;
			states.send_event("to_opened");

func _ready() -> void:
	interaction.registry(use);

func haverst() -> void:
	if potato:
		Players.sprouts = max(Players.sprouts - 1, 0);
		potato.queue_free();
		potato = null;
		states.send_event("to_initial");
func plant() -> void:
	if states.get_state() == "opened" && !potato:
		states.send_event("to_closed");
		var potato_scene : PackedScene = Scenes.get_resource("Potato");
		potato = potato_scene.instantiate();
		add_child(potato);
		potato.global_position = center.global_position;
		potato.progress = initial_grow_level;

func use(by : Node) -> void:
	if by is Player && !by.states.get_state() in ["dig", "doing", "watering"]:
		match states.get_state():
			"opened":
				if Players.potatoes > 0:
					if Game.is_flipped(by): by.plant(self, right.global_position);
					else: by.plant(self, left.global_position);
			"closed":
				if potato && potato.progress >= 1.0:
					if Game.is_flipped(by): by.haverst(self, right.global_position);
					else: by.haverst(self, left.global_position);
				elif Players.water > 0:
					if Game.is_flipped(by): by.water_plants(self, right.global_position);
					else: by.water_plants(self, left.global_position);
			"wet":
				pass;
			_:
				if Game.is_flipped(by): by.dig(self, right.global_position);
				else: by.dig(self, left.global_position);
	elif by is Player:
		by.stop();
	elif by is Goblin:
		if Game.is_flipped(by): by.haverst(self, right.global_position);
		else: by.haverst(self, left.global_position);

func update_sprite() -> void:
	var state : String = states.get_state();
	if state == "wet": sprite.play("wet");
	else: sprite.play(state + ("_focused" if interaction.is_focused() else ""));

func _on_interaction_focus() -> void:
	update_sprite();
func _on_interaction_unfocus() -> void:
	update_sprite();
func _on_inital_state_entered() -> void:
	update_sprite();
func _on_opening_state_entered() -> void:
	update_sprite();
func _on_opened_state_entered() -> void:
	update_sprite();
func _on_closed_state_entered() -> void:
	update_sprite();
func _on_wet_state_entered() -> void:
	clock.reset();
	update_sprite();

func _on_wet_state_processing(delta) -> void:
	clock.step(delta * Game.clock_speed);
	if clock.hours >= 18:
		states.send_event("to_closed");
		if potato: potato.progress += 0.25;
