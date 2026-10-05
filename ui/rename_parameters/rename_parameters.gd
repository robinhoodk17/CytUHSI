extends Button

var script_file_name : String = "make_all_file_names_equal.R"


func _ready() -> void:
	button_up.connect(run_r_file)

func run_r_file() -> void:
	var script_name = str(GlobalVariables.r_scripts_folder, script_file_name)
	OS.execute(GlobalVariables.r_script_exe, [script_name, GlobalVariables.r_scripts_folder, GlobalVariables.json_files])
