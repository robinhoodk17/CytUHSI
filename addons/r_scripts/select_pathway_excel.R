library(tcltk)
library(readxl)
library(openxlsx)

filters = matrix(c("xls", "xlsx"), 1, 2)
pathways_file_name <- tk_choose.files(caption = "Select your excel file with pathways and markers.", filters = filters)
parameter_names = read.xlsx(pathways_file_name, sheet = 1)


errors_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/errors"
storing_pathways_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/pathways"

found_error = ""
if (  !("pathway" %in%  names(parameter_names))  )
{
  found_error = "you_forgot_pathway"
}
if (  !("marker" %in%  names(parameter_names))  )
{
  found_error = "you_forgot_marker"
}
if (found_error != ""){
  cat(found_error, file = errors_file)
}
cat(pathways_file_name,file = storing_pathways_file)
