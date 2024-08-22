class_name Goblin
extends Character

@export var navigation : NavigationAgent2D;
@export var bar : Bar;
@export var sound_attack : AudioStreamPlayer;
const attack_distance : float = 20;
const speed : float = 25.0;

var can_update_navigation : bool = true;
var target : Node2D = null :
	set(value):
		if target is Spot: Master.dismark_spot(target);
		target = value;
		if target is Spot: Master.mark_spot(target);

func _ready() -> void:
	super._ready();
	Master.amount += 1;
	health.changed.connect(func(value : float): bar.update(value));

#region Control
func flip(left : bool) -> void:
	super.flip(left);
	Game.flip(bar.get_parent(), left);
func move(run : bool = false) -> bool:
	if navigation.is_navigation_finished(): 
		velocity = velocity.move_toward(Vector2.ZERO, speed);
	else:
		var next_position: Vector2 = navigation.get_next_path_position();
		var direction : Vector2 = global_position.direction_to(next_position);
		var new_velocity : Vector2 = direction * speed * (4.0 if run else 1.0);
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
	if target && target is Player && target.global_position.distance_to(global_position) <= attack_distance:
		states.send_event("to_attack");
		return true;
	return false;
func interact() -> bool:
	if target && target is Spot && navigation.is_navigation_finished():
		var interaction : Interaction = actor.get_nearest_interaction(self);
		if interaction.get_parent() == target && target.potato: 
			interaction.action.emit(self);
			return true;
	return false;
#endregion

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
	if !spot: spot = Master.get_nearest_spot(global_position);
	if player_distance <= attack_distance:
		navigation.target_position = global_position;
		target = nearest_player;
		navigation.target_desired_distance = 20.0;
		navigation.path_desired_distance = 4.0;
		spot = null;
	elif player_distance <= 120 || !spot:
		navigation.target_position = nearest_player.global_position;
		target = nearest_player;
		spot = null;
		navigation.target_desired_distance = 20.0;
		navigation.path_desired_distance = 4.0;
	else:
		navigation.target_desired_distance = 14.0;
		navigation.path_desired_distance = 4.0;
		navigation.target_position = spot.global_position;
		target = spot;
	can_update_navigation = false;

#region Enter / Exit
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
	hitbox.visible = false;
func _on_hurt_state_entered() -> void:
	action_progress = 0;
	action = "";
	spot = null;
	navigation.target_position = global_position;
	sprite.play("hurt");
	await sprite.animation_finished;
	states.send_event("to_idle");
func _on_doing_state_entered() -> void:
	sprite.play("walk");
func _on_death_state_entered() -> void:
	bar.visible = false;
	Master.amount -= 1;
	target = null;
	velocity = Vector2.ZERO;
	sprite.play("death");
	await sprite.animation_finished;
	var tween : Tween = create_tween();
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 2.0).set_delay(1.0);
	tween.tween_callback(queue_free);
	tween.play();
#endregion

#region Process
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
	var attacked : bool = sprite.frame == 13;
	if attacked && !hitbox.visible:
		voice.switch_to("Attack " + str(randi_range(1, 3)));
		sound_attack.play();
		hitbox.visible = true;
		hitbox.hurt();
	elif !attacked:
		hitbox.visible = false;
	var finished : bool = !sprite.is_playing();
	if finished && !attack(): states.send_event("to_idle");
	elif finished: 
		sprite.play("attack");
		health.hurt(1);
func _on_hurt_state_processing(_delta) -> void:
	velocity = Vector2.ZERO;
func _on_doing_state_processing(delta) -> void:
	if move(true): 
		return;
	elif sprite.animation != "doing":
		velocity = Vector2.ZERO;
		sprite.play("doing");
	action_progress += 0.5 * delta;
	if action_progress >= 1.0:
		action_progress -= 1.0;
		match action:
			"haverst":
				if spot && spot.potato: spot.haverst();
				target = null;
				voice.switch_to("Laugh " + str(randi_range(1, 3)));
				health.heal(50);
				stop();
func _on_death_state_processing(_delta: float) -> void:
	velocity = Vector2.ZERO;
#endregion

#region Special
func _on_death() -> void:
	stop(true);
func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity;
func _on_relay_timeout() -> void:
	can_update_navigation = true;
#endregion
