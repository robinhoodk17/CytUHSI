extends Control

@onready var exit: Button = $MarginContainer/ScrollContainer/GridContainer/Exit

func _ready() -> void:
	exit.button_up.connect(func():
		get_tree().quit())
	
	FileLoader.clean_jsons()
	#await get_tree().create_timer(1.5).timeout
	#
	#var script_name = str(GlobalVariables.r_scripts_folder, "hello_world.R")
	#print_debug(script_name)
	#OS.execute(GlobalVariables.r_script_exe, [script_name, GlobalVariables.r_scripts_folder, GlobalVariables.json_files])
