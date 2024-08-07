extends CanvasLayer

@onready var timer_label = %TimerLabel
@onready var meat_label = %MeatLabel
#@onready var gold_label = $GoldLabel

func _process(delta):
	meat_label.text = str(GameManager.meat_counter)
	timer_label.text = GameManager.etim_str
