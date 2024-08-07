extends CanvasLayer

@export var restart_cooldown = 7.0

@onready var timen_label = %TimeNLabel
@onready var monstersn_label = %MonstersNLabel

func _ready():
	timen_label.text = GameManager.etim_str
	monstersn_label.text = str(GameManager.monsters_defeated_counter)
	
func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart()
		
func restart():
	GameManager.reset()
	get_tree().reload_current_scene()

