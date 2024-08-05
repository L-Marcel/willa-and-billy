extends CanvasLayer

@export var control : Control;
@export var description_label : Label;
@export var tip_label : Label;
@export var title_label : Label;
var can_reset : bool = false;

signal reset;

func game_over(description : String, type : int = 0):
	if !control.visible:
		get_tree().paused = true;
		match type:
			0:
				tip_label.text = "Apertem Enter ou Select para tentar novamente";
				title_label.text = "Fracasso";
			1:
				tip_label.text = "Apertem Enter ou Select para tentar novamente";
				title_label.text = "Fracasso";
			2:
				tip_label.text = "Apertem Enter ou Select para jogar novamente ou F8 para fechar o jogo.";
				title_label.text = "Vitória";
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
func start():
	tip_label.modulate.a = 0.0;
	control.visible = false;
	get_tree().paused = false;
func _ready():
	start();

func _process(_delta):
	if !control.visible:
		pass;
		#game_over("O alarme tocou! Os dados se perderam...", true);
	if Input.is_action_just_pressed("close"):
		get_tree().quit();
	if Input.is_action_just_pressed("start") && tip_label.modulate.a >= 0.25 && can_reset:
		can_reset = false;
		reset.emit();
		start();
		get_tree().change_scene_to_file("res://Game.tscn");
