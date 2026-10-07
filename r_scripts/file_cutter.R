tryCatch({
  library(flowCore)
  library(tcltk)
},error = function(error){
  install.packages("flowCore")
  install.packages("tcltk")
})


#args[1] has the r_scripts. args[2] has the json scripts
args <- commandArgs(trailingOnly = TRUE)
working_folder_file = paste(args[2],"\\working_folder",sep = "")
#working_folder_file =  "C:/Users/UHSI/Documents/r/r_scripts/jsons/working_folder"

fcs_folder = tk_choose.dir(caption = "Select the folder with your FCS files")
#so that we can communicate later with the file_cutter_confirm
cat(fcs_folder, file = working_folder_file)
temp = list.files(pattern="*fcs", path = fcs_folder)
temp = lapply(temp,function(x) paste(fcs_folder,"\\", x,sep = ""))

file = temp[[1]]
fcs = read.FCS(file, truncate_max_range = FALSE)
df = as.data.frame(fcs@exprs)
collapsed = paste(names(df), collapse = ",")
resulting_file = paste(args[2],"\\target_names",sep = "")
#resulting_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/target_names"

cat(collapsed, file = resulting_file)
