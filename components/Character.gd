class_name Character
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateMachine;
@export var health : Health;
@export var hurtbox : Hurtbox;
@export var hitbox : Hitbox;
@export var collisions : Array[CollisionShape2D];
@export var actor : Actor;

var damage : float = 20.0;
var damage_reduction : float = 0.0;
var cancel_attack_chance : float = 0.5;
var action_progress : float = 0;
var action : String = "";
var spot : Spot;

func _ready():
	for collision in collisions:
		collision.shape = collision.shape.duplicate(true);
func _physics_process(_delta) -> void:
	move_and_slide();

func flip(left : bool) -> void:
	Game.flip(self, left);
func hurt(_damage : float) -> void:
	health.hurt(_damage * (1.0  - damage_reduction));
	var continue_attack : bool = (
		randf_range(0.0, 1.0) <= (1.0 - cancel_attack_chance) && 
		states.get_state() == "attack"
	);
	if continue_attack: return;
	if states.get_state() != "hurt":
		states.send_event("to_hurt");
	else:
		sprite.frame = 0;
