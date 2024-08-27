extends CanvasLayer

@export var clock_speed : float = 4.0;
@export var control : Control;
@export var description_label : Label;
@export var tip_label : Label;
@export var title_label : Label;
@export var nature : AudioPlayer;
@export var music : AudioPlayer;

var can_reset : bool = false;
var clock : Clock = Clock.new(1, 6);
var world : World = null;

signal reset;

func game_over(description : String, type : int = 0) -> void:
	if !control.visible:
		get_tree().paused = true;
		match type:
			0:
				tip_label.text = "Apertem Enter ou Select para tentar novamente ou F8 para fechar o jogo.";
				title_label.text = "Tragédia";
				music.switch_to("Death");
			1:
				tip_label.text = "Apertem Enter ou Select para jogar novamente ou F8 para fechar o jogo.";
				title_label.text = "Fracasso";
				music.switch_to("Fail");
		description_label.modulate.a = 0.0;
		tip_label.modulate.a = 0.0;
		control.modulate.a = 0.0;
		control.visible = true;
		description_label.text = description;
		var tween : Tween = create_tween();
		tween.tween_property(control, "modulate", Color.WHITE, 2.0);
		tween.tween_property(description_label, "modulate", Color.WHITE, 0.5).set_delay(1.0);
		tween.tween_property(tip_label, "modulate", Color.WHITE, 0.5).set_delay(1.5);
		tween.play();
		can_reset = true;
func start() -> void:
	tip_label.modulate.a = 0.0;
	control.visible = false;
	Players.reset();
	get_tree().paused = false;
	music.switch_to("Default");
func _ready() -> void:
	clock.stage_changed.connect(_on_stage_changed);
	start();
func _process(_delta) -> void:
	if Input.is_action_just_pressed("close"):
		get_tree().quit();
	if Input.is_action_just_pressed("start") && tip_label.modulate.a >= 0.25 && can_reset:
		can_reset = false;
		reset.emit();
		start();
		get_tree().change_scene_to_file("res://Main.tscn");
func _on_stage_changed(stage : Clock.DayStage) -> void:
	match stage:
		Clock.DayStage.DAWN:
			nature.switch_to("Dawn");
		Clock.DayStage.MORNING:
			nature.switch_to("Morning");
		Clock.DayStage.AFTERNOON:
			nature.switch_to("Morning");
		Clock.DayStage.EVENING:
			nature.switch_to("Night");
		Clock.DayStage.NIGHT:
			nature.switch_to("Night");
	
func flip(node : Node, left : bool) -> void:
	if node is Node2D || node is Control:
		if left:
			node.scale.y = -abs(node.scale.y);
			node.rotation_degrees = 180;
		else:
			node.scale.y = abs(node.scale.y);
			node.rotation_degrees = 0;
func is_flipped(node : Node) -> bool:
	if node is Node2D:
		return node.scale.y < 0 && abs(node.rotation_degrees) == 180;
	else:
		return false;
