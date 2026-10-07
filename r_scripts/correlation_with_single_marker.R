tryCatch({
  library(flowCore)
  library(BiocManager)
  library(tidyFlowCore)
  library(reshape2)
  library(readxl)
  library(openxlsx)
  library(readr)
  library(data.table)
  library(dplyr)
  library(networkD3)
  library(Hmisc)
  library(igraph)
  library(plotly)
  library(plyr)
  library(tibble)
  library(tcltk)
},error = function(error){
  install.packages("flowCore")
  install.packages("BiocManager")
  install.packages("tidyFlowCore")
  install.packages("reshape2")
  install.packages("readxl")
  install.packages("openxlsx")
  install.packages("readr")
  install.packages("data.table")
  install.packages("dplyr")
  install.packages("networkD3")
  install.packages("Hmisc")
  install.packages("igraph")
  install.packages("plotly")
  install.packages("plyr")
  install.packages("tibble")
  install.packages("tcltk")
})



data_folder = tk_choose.dir(caption = "Select the folder with your samples. They must be .csv files")

#PLease enter here the name of the folder where you wish to save the plots (remember to change all \ characters)
results_folder = tk_choose.dir(caption = "Select the folder to store your results")
target_name_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/target_names"
target_name <- readLines(target_name_file)

endoglin = target_name
result_file_name = paste(results_folder, "\\", "correlation_with", endoglin, ".csv", sep = "")

correlation_method = "pearson"
debug_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/debug_file"
#cat(target_name, file = debug_file)


temp = list.files(pattern="*csv", path = data_folder)
sample_names = gsub(".csv", "", temp)
temp = lapply(temp,function(x) paste(data_folder,"\\", x,sep = ""))
df.list <- lapply(temp, function(x) read.csv(x, header = TRUE, check.names = FALSE))
parameter_names = names(df.list[[1]])
results_names = c("sample_name", parameter_names)

results = data.frame(matrix(ncol = length(results_names)))
names(results) = results_names

sample_number = 1
for (sample in df.list){
  result_array = sample_names[sample_number]
  array_with_endoglin_data = sample[[endoglin]]
  for (marker_name in parameter_names)
  {
    array_with_marker_data = sample[[marker_name]]
    correlation = cor.test(array_with_endoglin_data,array_with_marker_data)$estimate[[1]]
    result_array = c(result_array, correlation)
  }
  results = rbind(results, result_array)
  sample_number = sample_number + 1
}





write.csv(results, file = result_file_name, row.names = FALSE)
