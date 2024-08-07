extends Node2D

@export var value = 0

func _ready():
	%Label.text = str(value)
