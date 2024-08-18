class_name Player
extends Character

@export var data : PlayerData;
@export var control : ControlData;
@export var actor : Actor;
@export var collisions : Array[CollisionShape2D];
var productivity : float = 1.0;
var action_progress : float = 0;
var action : String = "";
var move_to : Vector2;
var spot : Spot;

func _ready() -> void:
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
	health.death.connect(_on_death);
	Game.clock.stage_changed.connect(_on_stage_changed);
	
func flip(left : bool)  -> void:
	Game.flip(self, left);
func move(run : bool = false) -> bool:
	var direction : Vector2 = Input.get_vector(control.left, control.right, control.up, control.down);
	if direction:
		velocity = direction * data.speed * (1.5 if run else 1.0);
		flip(direction.x < 0);
	else:
		velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	var in_movement : bool = velocity != Vector2.ZERO;
	if in_movement && Input.is_action_pressed(control.run):
		states.send_event("to_run");
		return true;
	elif in_movement:
		states.send_event("to_walk");
		return true;
	else:
		states.send_event("to_idle");
		return false;
func follow(delta : float, at_position : Vector2 = move_to) -> void:
	var diference : Vector2 = at_position - global_position;
	var run : bool = Input.is_action_pressed(control.run);
	var bonus : float = 1.5 if run else 1.0;
	var direction : Vector2 = diference.normalized();
	if direction:
		velocity = direction * data.speed * bonus;
		if diference.length() <= (velocity * delta).length():
			velocity = (diference / delta) if delta != 0 else Vector2.ZERO;
		flip(velocity.x < 0);
		if run && sprite.animation != "run": sprite.play("run");
		elif !run && sprite.animation != "walk": sprite.play("walk");
	else:
		velocity = Vector2.ZERO;
		sprite.play("idle");
func attack() -> bool:
	if Input.is_action_pressed(control.attack):
		states.send_event("to_attack");
		return true;
	return false;
func interact() -> bool:
	if Input.is_action_just_pressed(control.interact):
		actor.interact_with_nearest(self);
		return true;
	return false;
	
#region Actions
func stop(death : bool = false) -> void:
	action_progress = 0;
	action = "";
	move_to = Vector2.ZERO;
	spot = null;
	states.send_event("kill" if death else "stop");
func sleep() -> void:
	states.send_event("to_sleeping");
func collect_water() -> void:
	if Players.water < 10:
		action = "water";
		move_to = global_position;
		states.send_event("to_doing");
func plant(at : Spot, at_position : Vector2) -> void:
	spot = at;
	move_to = at_position;
	action = "plant";
	states.send_event("to_doing");
func haverst(at : Spot, at_position : Vector2) -> void:
	spot = at;
	move_to = at_position;
	action = "haverst";
	states.send_event("to_doing");
func dig(at : Spot, at_position : Vector2) -> void:
	spot = at;
	if !spot.opened.is_connected(_on_spot_opened):
		spot.opened.connect(_on_spot_opened);
	move_to = at_position;
	states.send_event("to_dig");
func water_plants(at : Spot, at_position : Vector2) -> void:
	spot = at;
	move_to = at_position;
	states.send_event("to_watering");
#endregion

func _physics_process(_delta) -> void:
	move_and_slide();
func _process(delta) -> void:
	if visible: health.hurt(Game.clock_speed * data.energy_drop * (delta / 48.0));

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
func _on_watering_state_entered() -> void:
	sprite.play("walk");
	health.hurt(1);
func _on_dig_state_entered() -> void:
	sprite.play("walk");
func _on_doing_state_entered() -> void:
	sprite.play("walk");
func _on_doing_state_exited() -> void:
	sprite.speed_scale = 1.0;
func _on_sleeping_state_entered() -> void:
	visible = false;
func _on_sleeping_state_exited() -> void:
	visible = true;
func _on_death_state_entered() -> void:
	velocity = Vector2.ZERO;
	sprite.play("death");
	await sprite.animation_finished;
	if data.name == "Willa": Game.game_over("Willa não sobreviveu...");
	else: Game.game_over("Billy não sobreviveu...");

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
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	hitbox.disabled = sprite.frame != 6;
	var finished : bool = !sprite.is_playing();
	if finished && !attack(): states.send_event("to_idle");
	elif finished: 
		sprite.play("attack");
		health.hurt(1);
func _on_hurt_state_processing(_delta) -> void:
	pass;
func _on_watering_state_processing(delta) -> void:
	if interact(): return;
	if move_to != global_position:
		follow(delta);
		return;
	elif sprite.animation != "watering" && spot:
		velocity = Vector2.ZERO;
		flip(spot.global_position.x < global_position.x);
		sprite.play("watering");
		Players.water = max(0, Players.water - 1);
	if spot && spot.states.get_state() == "closed" && sprite.frame == 4:
		spot.states.send_event("to_wet");
		stop();
func _on_dig_state_processing(delta) -> void:
	if interact(): return;
	if move_to != global_position:
		follow(delta);
		return;
	elif sprite.animation != "dig" && spot:
		velocity = Vector2.ZERO;
		flip(spot.global_position.x < global_position.x);
		sprite.play("dig");
	if spot && spot.states.get_state() == "initial" && sprite.frame == 4:
		spot.states.send_event("to_opening");
		return;
	if spot && spot.states.get_state() == "opening" && sprite.frame == 7:
		spot.progress += productivity * 5 * delta;
		health.hurt(1 * delta);
func _on_doing_state_processing(delta) -> void:
	if interact(): return;
	if move_to != global_position:
		follow(delta);
		return;
	elif sprite.animation != "doing":
		velocity = Vector2.ZERO;
		sprite.play("doing");
		match action:
			"plant":
				flip(spot.global_position.x < global_position.x);
				sprite.speed_scale = data.plant_speed;
			_:
				sprite.speed_scale = 1.0;
	action_progress += productivity * 0.5 * delta * sprite.speed_scale;
	if action_progress >= 1.0:
		action_progress -= 1.0;
		match action:
			"water":
				health.hurt(1);
				Players.water = clamp(Players.water + 1, 0, 10);
				if Players.water >= 10:
					stop();
			"plant":
				if !spot || spot.potato: return;
				Players.sprouts += 1;
				Players.potatoes = max(0, Players.potatoes - 1);
				health.hurt(1);
				spot.plant();
				stop();
			"haverst":
				health.hurt(1);
				if spot && spot.potato:
					if randf_range(0, 1) >= data.chance_of_losing_havest:
						Players.potatoes += randi_range(2, 3);
					spot.haverst();
				stop();
func _on_sleeping_state_processing(delta) -> void:
	interact();
	health.heal(Game.clock_speed * data.energy_gain * (delta / 19.2));

func _on_stage_changed(stage : Clock.DayStage) -> void:
	match stage:
		Clock.DayStage.DAWN:
			productivity = data.night_productivity;
		Clock.DayStage.MORNING:
			productivity = data.morning_productivity;
		Clock.DayStage.AFTERNOON:
			productivity = data.morning_productivity;
		Clock.DayStage.EVENING:
			productivity = data.night_productivity;
		Clock.DayStage.NIGHT:
			productivity = data.night_productivity;
func _on_spot_opened() -> void:
	await sprite.animation_looped;
	stop();
func _on_death() -> void:
	stop(true);
