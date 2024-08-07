class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed = 3.0
@export_category("Weapon")
@export var weapon_damage = 2
@export_category("Magic")
@export var magic_damage = 1
@export var magic_interval = 10.0
@export var magic_scene: PackedScene
@export_category("Life")
@export var health = 50
@export var max_health = 100
@export var death_prefab: PackedScene

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var weapon_area = $WeaponArea
@onready var hitbox = $Hitbox
@onready var health_progress_bar = $HealthProgressBar

var input_vector: Vector2
var is_running = false
var was_running = false
var is_attacking = false
var attack_cooldown = 0.0
var hitbox_cooldown = 0.0
var magic_cooldown = 15.0

signal recover(value:int)

func _ready():
	GameManager.player = self
	recover.connect(
		func(value: int):
			GameManager.meat_counter += 1
	)

func _process(delta):
	read_input()
	
	#Processar animação e rotação de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
		
	# Processar dano
	update_hitbox_detection(delta)
	
	# Processar ritual
	update_magic(delta)
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta):
	GameManager.player_position = position
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.15)
	move_and_slide()

func read_input():
	# Obter input_vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar "deadzone" de input_vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	# Atualizar is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation():
	# Rodar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
				
func rotate_sprite():
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func attack():
	if is_attacking:
		return
		
	# Rodar animação
	animation_player.play("attack_side")
	
	# Configurar temporizador
	attack_cooldown = 0.6
	
	# Marcar ataque
	is_attacking = true
	
func deal_damage():
	var bodies = weapon_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.25:
				enemy.damage(weapon_damage)
			
func update_attack_cooldown(delta: float):
# Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_hitbox_detection(delta: float):
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	hitbox_cooldown = .5
	
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = enemy.damage_player
			damage(damage_amount)

func update_magic(delta: float):
	magic_cooldown -= delta
	if magic_cooldown > 0: return
	magic_cooldown = magic_interval
	
	# Criar ritual
	var magic = magic_scene.instantiate()
	magic.damage_amount = magic_damage
	add_child(magic)
	

func damage(amount: int):
	if health <= 0: return
	
	health -= amount
	print("Goblin recebeu dano de ", amount,". Vida total: ", health)

	# Piscar node
	modulate = Color.ORANGE_RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, .3)

# Processar morte
	if health <= 0:
		die()
	
func die():
	# Game Over
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Goblin está morto!")
	
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Goblin foi curado em ", health, " pontos. Vida total: ", health, "/", max_health)
	return health
