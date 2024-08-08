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
	Game.clock.stage_changed.connect(_on_stage_changed);
	
func flip(left : bool):
	Game.flip(self, left);

func move(run : bool = false) -> bool:
	var direction = Input.get_vector(control.left, control.right, control.up, control.down);
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
func follow(delta : float, at_position : Vector2 = move_to):
	var diference = at_position - global_position;
	var run = Input.is_action_pressed(control.run);
	var bonus = 1.5 if run else 1.0;
	var direction = diference.normalized();
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
func interact():
	if Input.is_action_just_pressed(control.interact):
		actor.interact_with_nearest(self);
	
#region Actions
func stop():
	action_progress = 0;
	action = "";
	move_to = Vector2.ZERO;
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
	spot.opened.connect(_on_spot_opened);
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
	hitbox.disabled = sprite.frame != 6;
	var finished = !sprite.is_playing();
	if finished && !attack(): states.send_event("to_idle");
	elif finished: sprite.play("attack");
func _on_hurt_state_processing(delta):
	pass;
func _on_watering_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	pass;
func _on_dig_state_processing(delta):
	interact();
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
func _on_doing_state_processing(delta):
	velocity = velocity.move_toward(Vector2.ZERO, data.speed);
	action_progress += productivity * 0.5 * delta;
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

func _on_stage_changed(stage : Clock.DayStage):
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
func _on_spot_opened():
	await sprite.animation_looped;
	stop();
