extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate = 60.0
@export var spawn_rate_per_min = 30.0
@export var wave_dur = 20.0
@export var break_intensity = 0.5

var time = 0.0

func _process(delta):
	# Game Over
	if GameManager.is_game_over: return
	time += delta
	
	# Dificuldade linear
	var spawn_rate = initial_spawn_rate + spawn_rate_per_min * (time/60)
	
	# Sistema de ondas
	var sin_wave = sin((time * TAU)/wave_dur)
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	spawn_rate *= wave_factor
	
	# Dificuldade
	mob_spawner.mobs_per_minute = spawn_rate
