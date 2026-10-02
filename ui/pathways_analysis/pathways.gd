extends Button

const PARAMETER_BUTTONS = preload("uid://cc3ovojtm7oiu")

var current_names : Dictionary[String, bool]
var initial_parameter_selection : String = "select_pathway_excel.R"
var checking_markers_are_well_named : String = "check_that_markers_are_well_named.R"
var check_markers_in_samples_are_well_named : String = "check_markers_in_samples_are_well_named.R"
var pathway_analysis_script : String = "pathway_analysis.R"

@onready var pathways_obtained_from_r_file : String = str(GlobalVariables.json_files, "pathways")
@onready var positive_population_folder : String = str(GlobalVariables.json_files, "folders")

var confirm_script_file_name : String = "file_cutter_confirm.R"
#var file_with_resulting_names : String = GlobalVariables.json_files + "deleteme"


@onready var pathway_analysis_wizard: Panel = $"../../../../PathwayAnalysisWizard"
@onready var processing_label: Label = $"../../../../PathwayAnalysisWizard/ProcessingLabel"
@onready var cancel: Button = $"../../../../PathwayAnalysisWizard/MainButtonsContainer/Cancel"
@onready var try_again_button: Button = $"../../../../PathwayAnalysisWizard/MainButtonsContainer/TryAgain"

@onready var errors: Control = $"../../../../PathwayAnalysisWizard/Errors"
@onready var forgot_marker_headers_error: MarginContainer = $"../../../../PathwayAnalysisWizard/Errors/ForgotMarkerHeadersError"
@onready var bad_marker_names_error: MarginContainer = $"../../../../PathwayAnalysisWizard/Errors/BadMarkerNamesError"
@onready var markers: Label = $"../../../../PathwayAnalysisWizard/Errors/BadMarkerNamesError/VBoxContainer/Markers"



func _ready() -> void:
	button_up.connect(start_selection)
	cancel.button_up.connect(hide_wizard)
	try_again_button.hide()
	try_again_button.button_up.connect(start_selection)
	hide_wizard()

func hide_wizard() -> void:
	pathway_analysis_wizard.hide()
	try_again_button.hide()
	FileLoader.clean_jsons()
	hide_errors()

func hide_errors() -> void:
	try_again_button.hide()
	for i in errors.get_children():
		i.hide()

func start_selection() -> void:
	print_debug("started executing pathway analysis")
	hide_errors()
	FileLoader.clean_jsons()
	pathway_analysis_wizard.show()
	processing_label.show()
	try_again_button.hide()
	await get_tree().create_timer(0.05).timeout
	
	var script_name = str(GlobalVariables.r_scripts_folder, initial_parameter_selection)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	print_debug("looking for  ", pathways_obtained_from_r_file)
	FileLoader.look_for_file(pathways_obtained_from_r_file)
	await FileLoader.file_found
	await get_tree().process_frame
	processing_label.hide()
	if FileAccess.file_exists(GlobalVariables.json_files + "errors"):
		try_again_button.show()
		forgot_marker_headers_error.show()
		return

	script_name = str(GlobalVariables.r_scripts_folder, checking_markers_are_well_named)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	FileLoader.look_for_file(positive_population_folder)
	await FileLoader.file_found
	print_debug("file found")
	await get_tree().process_frame
	if FileAccess.file_exists(GlobalVariables.json_files + "errors"):
		try_again_button.show()
		bad_marker_names_error.show()
		var error_file : FileAccess = FileAccess.open(GlobalVariables.json_files + "errors",FileAccess.READ)
		var concatenated : String = error_file.get_as_text()
		markers.text = concatenated
		return
	
	script_name = str(GlobalVariables.r_scripts_folder, check_markers_in_samples_are_well_named)
	processing_label.show()
	try_again_button.hide()
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	
	processing_label.hide()
	if FileAccess.file_exists(GlobalVariables.json_files + "errors"):
		try_again_button.show()
		bad_marker_names_error.show()
		var error_file : FileAccess = FileAccess.open(GlobalVariables.json_files + "errors",FileAccess.READ)
		var concatenated : String = error_file.get_as_text()
		markers.text = concatenated
		return
	script_name = str(GlobalVariables.r_scripts_folder, pathway_analysis_script)
	processing_label.show()
	try_again_button.hide()
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	
	processing_label.hide()
	hide_wizard()
	
	print_debug("finished executing pathway analysis")
