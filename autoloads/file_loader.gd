extends Node

signal file_found(_file_name_)
var file_name : String

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	#print_debug("looking")
	if FileAccess.file_exists(file_name):
		set_process(false)
		await get_tree().process_frame
		file_found.emit(file_name)

func look_for_file(_file_name) -> void:
	set_process(true)
	file_name = _file_name

func clean_jsons() -> void:
	var dir := DirAccess.open(GlobalVariables.json_files)
	if dir == null: printerr("Could not open folder"); return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		DirAccess.remove_absolute(GlobalVariables.json_files + file)
