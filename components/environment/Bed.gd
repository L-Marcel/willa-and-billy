extends StaticBody2D

@export var sprite : AnimatedSprite2D;
@export var interaction : Interaction;
@export var willa_icon : TextureRect;
@export var billy_icon : TextureRect;
@export var willa_position : Marker2D;
@export var billy_position : Marker2D;

var players : Array[Player] = [];

func _ready() -> void:
	sprite.play("unfocused");
	interaction.registry(sleep);
	Master.started.connect(_on_master_started);
	Master.ended.connect(_on_master_ended);

func update() -> void:
	willa_icon.visible = false;
	billy_icon.visible = false;
	
	if players.size() == 2 && Master.amount == 0 && Master.requested == 0:
		Engine.time_scale = 20.0;
	else: Engine.time_scale = 1.0;

	for player in players:
		player.voice.switch_to("None");
		if player.data.name == "Willa":
			willa_icon.visible = true;
			player.global_position = willa_position.global_position;
		else:
			billy_icon.visible = true;
			player.global_position = billy_position.global_position;
func sleep(by : Node) -> void:
	if by is Player && by.states.get_state() != "sleeping":
		players.append(by);
		by.sleep();
		by.add_collision_exception_with(Players.billy);
		by.add_collision_exception_with(Players.willa);
		interaction.remove_focus();
	elif by is Player:
		players.erase(by);
		by.stop();
		by.remove_collision_exception_with(Players.billy);
		by.remove_collision_exception_with(Players.willa);
		interaction.add_focus();
	update();

func _on_master_started(_dificult : int) -> void:
	update();
func _on_master_ended() -> void:
	update();
func _on_interaction_focus() -> void:
	sprite.play("focused");
func _on_interaction_unfocus() -> void:
	sprite.play("unfocused");
