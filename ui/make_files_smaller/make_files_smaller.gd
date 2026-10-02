extends Button

const PARAMETER_BUTTONS = preload("uid://cc3ovojtm7oiu")

var current_names : Dictionary[String, bool]
var script_file_name : String = "file_cutter.R"
var confirm_script_file_name : String = "file_cutter_confirm.R"
#var file_with_resulting_names : String = GlobalVariables.json_files + "deleteme"

var original_names_file : String = str(GlobalVariables.json_files, "target_names")
@onready var smaller_files_wizard: Panel = $"../../../../SmallerFilesWizard"
@onready var processing_label: Label = $"../../../../SmallerFilesWizard/ProcessingLabel"
@export var make_sure_panel : Panel
@onready var cancel: Button = $"../../../../SmallerFilesWizard/CheckboxesContainer/MainButtonsContainer/Cancel"
@onready var confirm: Button = $"../../../../SmallerFilesWizard/CheckboxesContainer/MainButtonsContainer/Confirm"
@export var final_confirm : Button
@export var cancel_at_last_minute : Button
@onready var checkboxes_container: VBoxContainer = $"../../../../SmallerFilesWizard/CheckboxesContainer"
@onready var parameter_buttons_container: GridContainer = $"../../../../SmallerFilesWizard/CheckboxesContainer/ScrollContainer/GridContainer"




func hide_wizard() -> void:
	make_sure_panel.hide()
	smaller_files_wizard.hide()
	for i : Node in parameter_buttons_container.get_children():
		i.queue_free()
	FileLoader.clean_jsons()
	
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	original_names_file = str(GlobalVariables.json_files, "target_names")
	button_up.connect(start_selection)
	cancel.button_up.connect(hide_wizard)
	confirm.button_up.connect(make_sure)
	final_confirm.button_up.connect(write_final_file)
	cancel_at_last_minute.button_up.connect(hide_wizard)
	hide_wizard()

func start_selection() -> void:
	smaller_files_wizard.show()
	processing_label.show()
	checkboxes_container.hide()
	make_sure_panel.hide()
	for i : Node in parameter_buttons_container.get_children():
		i.queue_free()
	await get_tree().create_timer(0.05).timeout
	
	var script_name = str(GlobalVariables.r_scripts_folder, script_file_name)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	FileLoader.look_for_file(original_names_file)
	await FileLoader.file_found
	
	processing_label.hide()
	var json_as_text = FileAccess.get_file_as_string(original_names_file)
	var all_parameters : PackedStringArray = json_as_text.split(",")
	current_names.clear()
	for i in all_parameters:
		current_names[i] = true
	update_checkboxes()

func update_checkboxes() -> void:
	checkboxes_container.show()
	for i in current_names.keys():
		current_names[i] = true
		var new_button = PARAMETER_BUTTONS.instantiate()
		new_button.get_child(0).text = i
		parameter_buttons_container.add_child(new_button)
		new_button.parameter_updated.connect(update_dictionary_with_parameters)
	
func update_dictionary_with_parameters(which_parameter, on_or_off) -> void:
	current_names[which_parameter] = on_or_off

func make_sure() -> void:
	make_sure_panel.show()

func write_final_file() -> void:
	make_sure_panel.hide()
	processing_label.show()
	checkboxes_container.hide()
	await get_tree().create_timer(0.05).timeout
	var all_names : String = ""
	var first : bool = true
	for i in current_names.keys():
		if current_names[i]:
			if first:
				all_names = i
				first = false
			else:
				all_names = all_names + "," + i
	#var packed : PackedStringArray = PackedStringArray(all_names)
	var file  = FileAccess.open(original_names_file, FileAccess.WRITE)
	file.store_string(all_names)
	file.close()
	var script_name = str(GlobalVariables.r_scripts_folder, confirm_script_file_name)
	OS.execute(GlobalVariables.r_script_exe, [script_name])
	hide_wizard()
