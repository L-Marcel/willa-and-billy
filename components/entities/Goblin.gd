class_name Goblin
extends Character

@export var navigation : NavigationAgent2D;
var speed: float = 80.0;

func _ready():
	super._ready();

func move(run : bool = false) -> bool:
	if navigation.is_navigation_finished(): 
		velocity = velocity.move_toward(Vector2.ZERO, speed);
		update_navigation();
	else:
		var next_position: Vector2 = navigation.get_next_path_position();
		var direction : Vector2 = global_position.direction_to(next_position);
		if direction:
			velocity = direction * speed * (1.5 if run else 1.0);
			flip(direction.x < 0);
	var in_movement : bool = velocity != Vector2.ZERO;
	if in_movement && run:
		states.send_event("to_run");
		return true;
	elif in_movement:
		states.send_event("to_walk");
		return true;
	else:
		states.send_event("to_idle");
		return false;
func attack() -> bool:
	return false;
func interact() -> bool:
	return false;

#region Actions
func stop(death : bool = false) -> void:
	action_progress = 0;
	action = "";
	spot = null;
	states.send_event("kill" if death else "stop");
func haverst(at : Spot, at_position : Vector2) -> void:
	spot = at;
	navigation.target_position = at_position;
	action = "haverst";
	states.send_event("to_doing");
#endregion

func update_navigation():
	#var willa_distance : float = global_position.distance_to(Players.willa.global_position);
	#var billy_distance : float = global_position.distance_to(Players.billy.global_position);
	#if willa_distance <= billy_distance: 
	navigation.target_position = Players.willa.global_position;
	#else: navigation.target_position = Players.billy.global_position;

func _physics_process(_delta):
	move_and_slide();

func _on_idle_state_entered() -> void:
	sprite.play("idle");
func _on_walk_state_entered() -> void:
	sprite.play("walk");
func _on_run_state_entered() -> void:
	sprite.play("run");
func _on_attack_state_entered() -> void:
	sprite.play("attack");
	health.hurt(1);
func _on_hurt_state_entered() -> void:
	sprite.play("hurt");
func _on_doing_state_entered() -> void:
	sprite.play("walk");
func _on_death_state_entered() -> void:
	velocity = Vector2.ZERO;
	sprite.play("death");
	await sprite.animation_finished;
	queue_free();

func _on_idle_state_processing(_delta) -> void:
	if attack(): return;
	interact();
	move();
func _on_walk_state_processing(_delta) -> void:
	if attack(): return;
	interact();
	move();
func _on_run_state_processing(_delta) -> void:
	if attack(): return;
	interact();
	move(true);
func _on_attack_state_processing(_delta) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, speed);
	hitbox.disabled = sprite.frame != 6;
	var finished : bool = !sprite.is_playing();
	if finished && !attack(): states.send_event("to_idle");
	elif finished: 
		sprite.play("attack");
		health.hurt(1);
func _on_hurt_state_processing(_delta) -> void:
	pass;
func _on_doing_state_processing(delta) -> void:
	if interact(): return;
	if !move(true): return;
	elif sprite.animation != "doing":
		velocity = Vector2.ZERO;
		sprite.play("doing");
	action_progress += 0.5 * delta;
	if action_progress >= 1.0:
		action_progress -= 1.0;
		match action:
			"haverst":
				health.hurt(1);
				if spot && spot.potato: spot.haverst();
				stop();

func _on_death() -> void:
	stop(true);
