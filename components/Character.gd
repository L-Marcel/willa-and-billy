class_name Character
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateMachine;
@export var health : Health;
@export var hurtbox : Hurtbox;
@export var hitbox : Hitbox;
@export var collisions : Array[CollisionShape2D];
@export var actor : Actor;
@export var voice : AudioPlayer;
@export var step : AudioStreamPlayer;
@export var sound_dig_start : AudioStreamPlayer;
@export var sound_dig_end : AudioStreamPlayer;

var damage : float = 20.0;
var damage_reduction : float = 0.0;
var cancel_attack_chance : float = 0.5;
var action_progress : float = 0;
var action : String = "";
var spot : Spot;

func _ready():
	sprite.frame_changed.connect(_on_frame_changed);
	step.volume_db = -8.0;
	for collision in collisions:
		collision.shape = collision.shape.duplicate(true);
func _physics_process(_delta) -> void:
	move_and_slide();
func _on_frame_changed() -> void:
	match sprite.animation:
		"walk", "run":
			if sprite.frame % 4 == 0: step.play();
		"dig":
			if sprite.frame == 2: sound_dig_start.play();
			elif sprite.frame == 9: sound_dig_end.play();

func flip(left : bool) -> void:
	Game.flip(self, left);
func hurt(_damage : float) -> void:
	health.hurt(_damage * (1.0  - damage_reduction));
	if voice && states.get_state() != "death": voice.switch_to("Hurt " + str(randi_range(1, 3)));
	var continue_attack : bool = (
		randf_range(0.0, 1.0) <= (1.0 - cancel_attack_chance) && 
		states.get_state() == "attack"
	);
	if continue_attack: return;
	if states.get_state() != "hurt":
		states.send_event("to_hurt");
	else:
		sprite.frame = 0;
