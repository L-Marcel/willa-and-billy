class_name Player
extends Character

@export var data : PlayerData;
@export var control : ControlData;
@export var actor : Actor;
@export var collisions : Array[CollisionShape2D];

func _ready():
	sprite.sprite_frames = data.sprite_frames;
	damage = data.damage;
	damage_reduction = data.energy_drop_on_damage;
	for collision in collisions:
		collision.shape = collision.shape.duplicate(true);
	if data.name == "Willa": 
		health = Players.willa_health;
		Players.willa = self;
	else: 
		health = Players.billy_health;
		Players.billy = self;
	
func flip(left : bool):
	Game.flip(self, !left);

func move(run : bool = false) -> bool:
	var direction = Input.get_vector(control.left, control.right, control.up, control.down);
	if direction:
		velocity = direction * data.speed * (1.5 if run else 1);
	else:
		velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	var in_movement = velocity != Vector2.ZERO;
	if in_movement && Input.is_action_pressed(control.run):
		flip(direction.x > 0);
		states.send_event("to_run");
		return true;
	elif in_movement:
		states.send_event("to_walk");
		flip(direction.x > 0);
		return true;
	else:
		states.send_event("to_idle");
		return false;
func attack() -> bool:
	if Input.is_action_pressed(control.attack):
		states.send_event("to_attack");
		return true;
	return false;
func interact():
	if Input.is_action_just_pressed(control.interact):
		actor.interact_with_nearest(self);
func sleep():
	states.send_event("to_sleeping");
func stop():
	states.send_event("stop");

func _physics_process(delta):
	move_and_slide();

func _on_idle_state_entered():
	sprite.play("idle");
func _on_walk_state_entered():
	sprite.play("walk");
func _on_run_state_entered():
	sprite.play("run");
func _on_attack_state_entered():
	sprite.play("attack");
func _on_hurt_state_entered():
	sprite.play("hurt");
func _on_watering_state_entered():
	sprite.play("watering");
func _on_dig_state_entered():
	sprite.play("dig");
func _on_doing_state_entered():
	sprite.play("doing");
func _on_sleeping_state_entered():
	visible = false;
func _on_sleeping_state_exited():
	visible = true;

func _on_idle_state_processing(_delta):
	if attack(): return;
	interact();
	move();
func _on_walk_state_processing(_delta):
	if attack(): return;
	interact();
	move();
func _on_run_state_processing(_delta):
	if attack(): return;
	interact();
	move(true);
func _on_attack_state_processing(_delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	hitbox.disabled = sprite.frame != 5;
	var finished = !sprite.is_playing();
	if finished && !attack(): states.send_event("to_idle");
	elif finished: sprite.play("attack");
func _on_hurt_state_processing(delta):
	pass;
func _on_watering_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	pass;
func _on_dig_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	pass;
func _on_doing_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	pass;
func _on_sleeping_state_processing(delta):
	interact();
