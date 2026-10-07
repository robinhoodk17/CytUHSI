
tryCatch({
  library(flowCore)
  library(BiocManager)
  library(tidyFlowCore)
  library(reshape2)
  library(readxl)
  library(openxlsx)
  library(readr)
  library(data.table)
  library(plyr)
  library(dplyr)
  library(networkD3)
  library(Hmisc)
  library(igraph)
  library(plotly)
  library(tcltk)
  library(stringi)
  library(tidyverse)
},error = function(error){
  install.packages("flowCore")
  install.packages("BiocManager")
  install.packages("tidyFlowCore")
  install.packages("reshape2")
  install.packages("readxl")
  install.packages("openxlsx")
  install.packages("readr")
  install.packages("data.table")
  install.packages("plyr")
  install.packages("dplyr")
  install.packages("networkD3")
  install.packages("Hmisc")
  install.packages("igraph")
  install.packages("plotly")
  install.packages("tcltk")
  install.packages("stringi")
  install.packages("tidyverse")
})



#args[1] has the r_scripts. args[2] has the json scripts
args <- commandArgs(trailingOnly = TRUE)


#result_folder <- tk_choose.dir(caption = "choose the folder with your candidates")
file_name = paste(args[2],"\\hello_world",sep = "")
print("hello")
print(file_name)
write(args[1], file_name)

