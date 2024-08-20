class_name Goblin
extends Character

@export var navigation : NavigationAgent2D;
const attack_distance : float = 20;
const speed : float = 80.0;
var can_update_navigation : bool = true;
var target : Node2D = null;

func _ready() -> void:
	super._ready();

func move(run : bool = false) -> bool:
	if navigation.is_navigation_finished(): 
		velocity = velocity.move_toward(Vector2.ZERO, speed);
	else:
		var next_position: Vector2 = navigation.get_next_path_position();
		var direction : Vector2 = global_position.direction_to(next_position);
		var new_velocity : Vector2 = direction * speed * (1.5 if run else 1.0);
		if navigation.avoidance_enabled: navigation.set_velocity(new_velocity);
		else: velocity = new_velocity;
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
	if target && target.global_position.distance_to(global_position) <= attack_distance:
		states.send_event("to_attack");
		return true;
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

func update_navigation(force : bool = false) -> void:
	if !can_update_navigation && !force: return;
	var willa_distance : float = global_position.distance_to(Players.willa.global_position);
	var billy_distance : float = global_position.distance_to(Players.billy.global_position);
	var player_distance : float = willa_distance;
	var nearest_player : Player = Players.willa;
	if willa_distance > billy_distance: 
		nearest_player = Players.billy;
		player_distance = billy_distance;
	if player_distance <= attack_distance:
		navigation.target_position = global_position;
		target = nearest_player;
	elif player_distance <= 200:
		navigation.target_position = nearest_player.global_position;
		target = nearest_player;
	else:
		navigation.target_position = global_position;
	can_update_navigation = false;

func _on_idle_state_entered() -> void:
	sprite.play("idle");
func _on_walk_state_entered() -> void:
	sprite.play("walk");
func _on_run_state_entered() -> void:
	sprite.play("run");
func _on_attack_state_entered() -> void:
	navigation.target_position = global_position;
	sprite.play("attack");
	health.hurt(1);
func _on_attack_state_exited() -> void:
	hitbox.disabled = true;
func _on_hurt_state_entered() -> void:
	action_progress = 0;
	action = "";
	spot = null;
	navigation.target_position = global_position;
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
	update_navigation();
	move();
func _on_walk_state_processing(_delta) -> void:
	if attack(): return;
	interact();
	update_navigation();
	move(navigation.target_position.distance_to(global_position) < 100);
func _on_run_state_processing(_delta) -> void:
	if attack(): return;
	interact();
	update_navigation();
	move(navigation.target_position.distance_to(global_position) < 100);
func _on_attack_state_processing(_delta) -> void:
	velocity = Vector2.ZERO;
	hitbox.disabled = sprite.frame != 8;
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

func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity;
func _on_relay_timeout() -> void:
	can_update_navigation = true;
