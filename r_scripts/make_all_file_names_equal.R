library(tcltk)

df <- read.csv(tk_choose.files(caption = "Select your csv file with the correct names. Empty names will delete the column"))
sample_folder <- choose.dir(caption = "choose the folder with your samples They must be csv files")


counts = 0
drops = {}
new_names = names(df)


for(i in names(df)){
  dropped_name = "X"
  if (counts > 0){
    dropped_name = paste("X.", counts, sep = "")
  }
  if (i == dropped_name){
    drops = c(drops, dropped_name)
    counts = counts + 1
  }
}


#directories = list.dirs(path = sample_folder, full.names = TRUE, recursive = FALSE)
files = list.files(sample_folder, full.names = TRUE)
for ( file_name in files){
  new_df = read.csv(file_name)
  names(new_df) = new_names
  corrected_df = new_df[ , !(names(new_df) %in% drops)]
  write.csv(corrected_df, file = file_name, row.names = FALSE)
}