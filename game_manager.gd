extends Node

signal game_over
var player: Player
var player_position: Vector2
var is_game_over = false
var etim = 0.0
var etim_str: String
var meat_counter = 0
var monsters_defeated_counter = 0

func _process(delta):
	etim += delta
	var etim_sec = floori(etim)
	var seconds = etim_sec % 60
	var minutes = etim_sec / 60
	etim_str = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	
	etim = 0.0
	etim_str = "00:00"
	meat_counter = 0
	monsters_defeated_counter = 0
	
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
