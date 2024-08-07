class_name Player
extends Character

@export var data : PlayerData;
@export var control : ControlData;
@export var actor : Actor;
@export var collisions : Array[CollisionShape2D];
var action_progress : float = 0;
var action : String = "";
var move_to : Vector2;
var spot : Spot;

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
	Game.flip(self, left);

func move(
	run : bool = false, 
	direction : Vector2 = Input.get_vector(control.left, control.right, control.up, control.down)
) -> bool:
	if direction:
		velocity = direction * data.speed * (1.5 if run else 1.0);
		flip(direction.x < 0);
	else:
		velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	var in_movement = velocity != Vector2.ZERO;
	if in_movement && Input.is_action_pressed(control.run):
		states.send_event("to_run");
		return true;
	elif in_movement:
		states.send_event("to_walk");
		return true;
	else:
		states.send_event("to_idle");
		return false;
func follow(at_position : Vector2 = move_to):
	var movement = at_position - global_position;
	move(false, movement.normalized() * min(movement.length(), 1));
	
func attack() -> bool:
	if Input.is_action_pressed(control.attack):
		states.send_event("to_attack");
		return true;
	return false;
func interact():
	if Input.is_action_just_pressed(control.interact):
		actor.interact_with_nearest(self);
func get_productivity():
	return data.afternoon_productivity;
	
#region Actions
func stop():
	action_progress = 0;
	action = "";
	spot = null;
	states.send_event("stop");
func sleep():
	states.send_event("to_sleeping");
func collect_water():
	if Players.water < 10:
		action = "water";
		states.send_event("to_doing");
func dig(at : Spot, at_position : Vector2):
	spot = at;
	move_to = at_position;
	states.send_event("to_dig");
#endregion

func _physics_process(_delta):
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
	sprite.play("walk");
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
	if !move_to.is_equal_approx(global_position):
		follow();
		return;
	elif sprite.animation != "dig" && spot:
		flip(spot.global_position.x < global_position.x);
		sprite.play("dig");
	
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	if spot && spot.states.get_state() == "opening" && sprite.frame == 7:
		spot.progress += get_productivity() * 5 * delta;
		if spot.progress == 1.0:
			spot.progress = 0;
			spot.states.send_event("to_opened");
			await sprite.animation_looped;
			stop();
func _on_doing_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	action_progress += get_productivity() * 0.5 * delta;
	if action_progress >= 1.0:
		action_progress -= 1.0;
		match action:
			"water":
				Players.water = clamp(Players.water + 1, 0, 10);
				if Players.water >= 10:
					stop();
	interact();
func _on_sleeping_state_processing(delta):
	interact();
