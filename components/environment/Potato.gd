class_name Potato
extends StaticBody2D

@export var sprite : AnimatedSprite2D;
@export var collision : CollisionShape2D;

var progress : float = 0.0 :
	set(value):
		progress = min(value, 1.0);
		if progress >= 0.25 && !visible: visible = true;
		if int(str(sprite.animation)) < int(progress * 4):
			sprite.play(str(int(progress * 4)));

func _ready() -> void:
	collision.shape = collision.shape.duplicate(true);
	sprite.play("1");
	visible = false;
