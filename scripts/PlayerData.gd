class_name PlayerData 
extends Resource

@export var name : StringName;
@export var sprite_frames : SpriteFrames;

@export_group("atributes")
@export var speed : float = 300;
@export var attack_speed : float = 1.4;
@export var damage : float = 20.0;
@export var chance_of_losing_havest : float = 0.00;
@export var sow_productivity : float = 1.0;
@export var morning_productivity : float = 1.0;
@export var night_productivity : float = 1.0;
@export var energy_drop : float = 1.0;
@export var energy_gain : float = 1.0;
@export var energy_drop_on_damage : float = 1.0;
