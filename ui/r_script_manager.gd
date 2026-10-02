extends Control

@onready var exit: Button = $MarginContainer/ScrollContainer/GridContainer/Exit

func _ready() -> void:
	exit.button_up.connect(func():
		get_tree().quit())
	
	FileLoader.clean_jsons()
