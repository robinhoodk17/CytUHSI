extends Button

const PARAMETER_BUTTONS = preload("uid://cc3ovojtm7oiu")

var correlation_single_marker_script : String = "correlation_with_single_marker.R"

@export var wizard : Panel
@export var line_edit : LineEdit
@export var start_analysis_button : Button

var original_names_file : String = str(GlobalVariables.json_files, "target_names")


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	original_names_file = str(GlobalVariables.json_files, "target_names")
	button_up.connect(start_selection)
	start_analysis_button.button_up.connect(start_analysis)
	hide_wizard()

func hide_wizard() -> void:
	wizard.hide()
	FileLoader.clean_jsons()
	hide_errors()

func hide_errors() -> void:
	pass
	


func start_selection() -> void:
	hide_errors()
	FileLoader.clean_jsons()
	wizard.show()
	line_edit.show()
	await get_tree().create_timer(0.5).timeout
	line_edit.grab_focus()

func start_analysis() -> void:
	var file  = FileAccess.open(original_names_file, FileAccess.WRITE)
	file.store_string(line_edit.text)
	file.close()
	await get_tree().create_timer(0.5).timeout
	var script_name = str(GlobalVariables.r_scripts_folder, correlation_single_marker_script)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	hide_wizard()
