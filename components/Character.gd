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
var action_progress : float = 0;
var action : String = "";
var spot : Spot;

func _ready():
	for collision in collisions:
		collision.shape = collision.shape.duplicate(true);

func flip(left : bool) -> void:
	Game.flip(self, left);
