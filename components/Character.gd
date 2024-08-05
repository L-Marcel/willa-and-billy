class_name Character
extends CharacterBody2D

@export var sprite : AnimatedSprite2D;
@export var states : StateChart;
@export var health : Health;
@export var hurtbox : Hurtbox;
@export var hitbox : Hitbox;

var damage : float = 20.0;
var damage_reduction : float = 0.0;
