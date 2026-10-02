extends Control

@onready var original_names_file : String = str(GlobalVariables.json_files, "target_names")

func _ready() ->void:
	var json_as_text = FileAccess.get_file_as_string(original_names_file)
	print_debug(json_as_text.split(",")[1])
