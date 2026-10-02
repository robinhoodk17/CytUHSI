extends Node
class_name GlobalVariablesClass

var r_script_exe : String = "C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe"
#"res://addons/R-4.4.1/bin/Rscript.exe"
##whenever you want to reference an R script, just use this var 
## and concatenate the name of the script at the end
var r_scripts_folder : String = "C:\\Users\\UHSI\\Documents\\CytUHSI\\r_scripts\\"
#"res://addons/r_scripts/"
var json_files : String = "C:\\Users\\UHSI\\Documents\\CytUHSI\\r_scripts\\jsons\\"
#"res://addons/r_scripts/jsons/"

######Example how to execute an R file
#var script_name = str(GlobalVariables.r_scripts_folder, "hello_world.R")
#OS.execute(GlobalVariables.r_script_exe, [script_name])
func _ready() -> void:
	#r_script_exe = ProjectSettings.globalize_path(r_script_exe)
	#r_script_exe = r_script_exe.replace("/", "\\") 
	#r_scripts_folder = ProjectSettings.globalize_path(r_scripts_folder)
	#r_scripts_folder = r_scripts_folder.replace("/", "\\")
	#json_files = ProjectSettings.globalize_path(json_files)
	#json_files = json_files.replace("/", "\\")
	
	print(r_script_exe)
	
	
