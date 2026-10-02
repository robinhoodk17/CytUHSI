library(flowCore)
library(tcltk)


working_folder_file =  "C:/Users/UHSI/Documents/r/r_scripts/jsons/working_folder"

fcs_folder = tk_choose.dir(caption = "Select your the folder with your FCS files")
#so that we can communicate later with the file_cutter_confirm
cat(fcs_folder, file = working_folder_file)
temp = list.files(pattern="*fcs", path = fcs_folder)
temp = lapply(temp,function(x) paste(fcs_folder,"\\", x,sep = ""))

file = temp[[1]]
fcs = read.FCS(file, truncate_max_range = FALSE)
df = as.data.frame(fcs@exprs)
collapsed = paste(names(df), collapse = ",")
resulting_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/target_names"

cat(collapsed, file = resulting_file)
