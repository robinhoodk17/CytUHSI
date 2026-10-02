library(tcltk)
library(readxl)
library(openxlsx)

positive_pop_folder <- tk_choose.dir(caption = "choose the folder with your positive populations. they should also be csv files")
folders_file = "C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/folders"
cat(positive_pop_folder, file = folders_file)



errors_file = "C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/errors"
storing_pathways_file = "C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/pathways"
pathways_file_name = readLines(storing_pathways_file)
parameter_names <- read.xlsx(pathways_file_name, sheet = 1)
unique_markers = unique(parameter_names$marker)
unique_pathways = unique(parameter_names$pathway)
problematic_markers = ""
for(i in unique_markers)
{
  temp = list.files(pattern=i, path = positive_pop_folder, ignore.case = FALSE)
  temp = lapply(temp,function(x) paste(positive_pop_folder,"\\", x,sep = ""))
  if (length(temp) < 1)
  {
    marker_plus_a = paste(i,"-A", sep = "")
    temp = list.files(pattern=marker_plus_a, path = positive_pop_folder, ignore.case = FALSE)
    temp = lapply(temp,function(x) paste(positive_pop_folder,"\\", x,sep = ""))
    if (length(temp) < 1)
    {
      if (problematic_markers == "")
      {
        problematic_markers = i
      }
      else
      {
        problematic_markers = paste(problematic_markers, i, sep = ",")
      }
    }
  }
}

if (problematic_markers != "")
{
  cat(problematic_markers, file = errors_file)
}