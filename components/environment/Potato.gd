class_name Potato
extends Node2D

@export var sprite : AnimatedSprite2D;
var progress : float = 0.0 :
	set(value):
		progress = value;
		if progress >= 0.25 && !visible:
			visible = true;
		elif progress >= 0.5 && int(str(sprite.animation)) < 2:
			sprite.play("2");
		elif progress >= 0.75 && int(str(sprite.animation)) < 3:
			sprite.play("3");
		elif progress >= 1.0 && int(str(sprite.animation)) < 4:
			sprite.play("4");

func _ready():
	sprite.play("1");
	visible = false;
