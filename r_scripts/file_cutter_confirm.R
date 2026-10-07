tryCatch({
  library(flowCore)
  library(tcltk)
  library(stringi)
  library(tidyverse)
  library(tidyFlowCore)
},error = function(error){
  install.packages("flowCore")
  install.packages("tcltk")
  install.packages("stringi")
  install.packages("tidyverse")
  install.packages("tidyFlowCore")
})


args <- commandArgs(trailingOnly = TRUE)

working_folder_file = paste(args[2],"\\working_folder",sep = "")
#working_folder_file =  "C:/Users/UHSI/Documents/r/r_scripts/jsons/working_folder"
fcs_folder = readLines(working_folder_file)

temp = list.files(pattern="*fcs", path = fcs_folder)
temp = lapply(temp,function(x) paste(fcs_folder,"\\", x,sep = ""))

parameter_names_file = paste(args[2],"\\target_names",sep = "")
parameter_names = readLines(parameter_names_file)
parameter_names = strsplit(parameter_names, ",")



escaped_params = gsub("\\)", "\\\\\\)", parameter_names[[1]])
escaped_params = gsub("\\(", "\\\\\\(", escaped_params)
escaped_params = gsub("\\*", "\\\\\\*", escaped_params)

targets = escaped_params[1]

for (i in 2:length(escaped_params))
{
  targets = paste(targets, escaped_params[i], sep = "|")
}

for (file in temp)
{
  #fcs = read.FCS(file)
  #df = as.data.frame(fcs@exprs)
  #cut_df = df[sapply(names(df), function(x) x %in% parameter_names[[1]])]
  #fcs = as_flowFrame(cut_df)
  fcs = read.FCS(file, column.pattern = targets, truncate_max_range = FALSE)
  write.FCS(fcs,file)
}
