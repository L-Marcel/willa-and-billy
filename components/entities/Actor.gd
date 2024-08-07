@icon("res://assets/icons/ViewportSpeed.svg")
class_name Actor
extends Area2D

var interactions : Dictionary;
var enabled : bool = true;
var ignore : Array[Node2D] = [];
var target : Interaction;

func get_nearest_interaction_body(node : Node2D):
	var nearest : Node2D = null;
	for object : Node2D in interactions:
		if is_instance_valid(object):
			var interaction = interactions[object] as Interaction;
			var distance = node.global_position.distance_to(object.global_position);
			var is_possible = object.has_node("Interaction") && interaction.is_possible();
			var is_nearest = !nearest || distance < node.global_position.distance_to(nearest.global_position);

			if is_nearest && is_possible:
				nearest = object;
		else:
			interactions.erase(object);
	return nearest;

func get_nearest_interaction(node : Node2D):
	var nearest = get_nearest_interaction_body(node);
	if nearest && enabled:
		return interactions[nearest] as Interaction;
	return null;

func interact_with_nearest(node : Node2D):
	var nearest = get_nearest_interaction_body(node);
	if nearest && enabled:
		var interaction = interactions[nearest] as Interaction;
		interaction.action.emit(node);

func _ready():
	monitoring = true;
	monitorable = true;
	input_pickable = false;
	body_entered.connect(_on_body_entered);
	body_exited.connect(_on_body_exited);
	ignore.append(get_parent());

func _process(_delta):
	var nearest : Interaction = get_nearest_interaction(get_parent());
	if nearest != target:
		if target: target.remove_focus();
		if nearest: nearest.add_focus();
		target = nearest;

func _on_body_entered(body):
	var skip = ignore.has(body);
	if !skip && body.has_node("Interaction"):
		var interaction = body.get_node("Interaction");
		if interaction is Interaction:
			var old_nearest : Interaction = get_nearest_interaction(get_parent());
			interactions[body] = interaction;
			body.tree_exiting.connect(_on_body_exited.bind(body));
			var nearest : Interaction = get_nearest_interaction(get_parent());
			if nearest == interaction && nearest:
				if old_nearest: old_nearest.remove_focus();
				nearest.add_focus();
				target = nearest;

func _on_body_exited(body):
	var skip = ignore.has(body);
	if interactions.has(body) && !skip:
		interactions[body].remove_focus();
		body.tree_exiting.disconnect(_on_body_exited);
		interactions.erase(body);
