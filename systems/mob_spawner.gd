class_name MobSpawner

extends Node2D

@export var creatures: Array[PackedScene]

@onready var path_follow_2d = %PathFollow2D

var mobs_per_minute = 60.0
var cooldown = 0.0

func _process(delta):
	# Game Over
	if GameManager.is_game_over: return
	
	# Temporizador
	cooldown -= delta
	if cooldown > 0: return
	
	# Frequência
	var interval = 60.0/mobs_per_minute
	cooldown = interval
	
	# Checar se ponto é válido
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b0010
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	# Instanciar um inimigo aleatório
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
	
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
	
