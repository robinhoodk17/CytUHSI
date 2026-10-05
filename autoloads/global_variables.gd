extends Node
class_name GlobalVariablesClass

var r_script_exe : String = "C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe"
##whenever you want to reference an R script, just use this var 
## and concatenate the name of the script at the end

var r_scripts_folder : String = "C:\\Users\\UHSI\\Documents\\CytUHSI\\r_scripts\\"
#"res://r_scripts/"

var json_files : String = "C:\\Users\\UHSI\\Documents\\CytUHSI\\r_scripts\\jsons\\"
#"res://r_scripts/jsons/"



######Example how to execute an R file
#var script_name = str(GlobalVariables.r_scripts_folder, "hello_world.R")
#OS.execute(GlobalVariables.r_script_exe, [script_name])
func _ready() -> void:
	var path : String = ""
	if OS.has_feature("editor"):
		path = ProjectSettings.globalize_path("res://").get_base_dir().get_base_dir()
	else:
		# Running from an exported project.
		# `path` will contain the absolute path to `hello.txt` next to the executable.
		# This is *not* identical to using `ProjectSettings.globalize_path()` with a `res://` path,
		# but is close enough in spirit.
		path = OS.get_executable_path().get_base_dir()
	print_debug("path to directory:  ", path)
	
	
	#r_script_exe = ProjectSettings.globalize_path("res://")
	#r_script_exe = r_script_exe.replace("CytUHSI/","R-4.4.1/bin/Rscript.exe")
	#r_script_exe = r_script_exe.replace("/", "\\")
	r_script_exe = path + "/R-4.4.1/bin/Rscript.exe"
	print_debug(r_script_exe)
	
	#r_scripts_folder = ProjectSettings.globalize_path("res://")
	#r_scripts_folder = r_scripts_folder.replace("CytUHSI/","r_scripts/")
	#r_scripts_folder = r_scripts_folder.replace("/", "\\")
	r_scripts_folder = path + "/r_scripts/"
	print_debug(r_scripts_folder)
	
	#json_files = ProjectSettings.globalize_path("res://")
	#json_files = json_files.replace("CytUHSI/","r_scripts/jsons/")
	#json_files = json_files.replace("/", "\\")
	json_files = path + "/r_scripts/jsons/"
	print_debug(json_files)
	
	
	
