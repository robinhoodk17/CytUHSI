extends Button

const PARAMETER_BUTTONS = preload("uid://cc3ovojtm7oiu")

var correlation_matrix_script : String = "correlation_matrix.R"

@export var wizard : Panel
@export var processing_label : Label

func _ready() -> void:
	button_up.connect(start_selection)
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
	processing_label.show()
	await get_tree().create_timer(0.05).timeout
	var script_name = str(GlobalVariables.r_scripts_folder, correlation_matrix_script)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	hide_wizard()
