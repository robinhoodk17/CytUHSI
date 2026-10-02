library(tcltk)
library(readxl)
library(openxlsx)

folders_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/folders"
positive_pop_folder <- readLines(folders_file)

storing_pathways_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/pathways"
pathways_file_name = readLines(storing_pathways_file)
parameter_names <- read.xlsx(pathways_file_name, sheet = 1)
unique_markers = unique(parameter_names$marker)
unique_pathways = unique(parameter_names$pathway)

sample_folder <- tk_choose.dir(caption = "choose the folder with your samples with CHANNEL values. They must be csv files")

cat(sample_folder, file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/channels")


temp = list.files(pattern="*csv", path = sample_folder)
temp = lapply(temp,function(x) paste(sample_folder,"\\", x,sep = ""))
df.list <- lapply(temp, function(x) read.csv(x, header = TRUE, check.names = FALSE))
markers_in_samples = names(df.list[[1]])


errors_file = "C:/Users/UHSI/Documents/r/r_scripts/jsons/errors"
problematic_markers = ""

for (marker in unique_markers)
{
  if (  !(marker %in% markers_in_samples)  )
  {
    marker_plus_a = paste(marker,"-A", sep = "")
    if ( !(marker_plus_a %in% markers_in_samples) )
    {
      if (problematic_markers == "")
      {
        problematic_markers = marker
      }
      else
      {
        problematic_markers = paste(problematic_markers, marker, sep = ",")
      }
    }
  }
}

if (problematic_markers != "")
{
  cat(problematic_markers, file = errors_file)
}
