library(reshape2)
library(readxl)
library(openxlsx)
library(readr)
library(data.table)
library(stringr)
library(dplyr)
library(networkD3)
library(Hmisc)
library(igraph)
library(plotly)
library(plyr)
library(tidyverse)
library(tcltk)
library(stringr)

folders_file = "C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/folders"
positive_pop_folder <- readLines(folders_file)

storing_pathways_file = "C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/pathways"
pathways_file_name = readLines(storing_pathways_file)
parameter_names <- read.xlsx(pathways_file_name, sheet = 1)
unique_markers = unique(parameter_names$marker)
unique_pathways = unique(parameter_names$pathway)

sample_folder <- readLines("C:/Users/UHSI/Documents/CytUHSI/r_scripts/jsons/channels")
scale_folder <- tk_choose.dir(caption = "choose the folder with your samples with SCALE values. They must be csv files")
results_folder <- tk_choose.dir(caption = "choose the folder where you want to store your results")

temp = list.files(pattern="*csv", path = sample_folder)
temp = lapply(temp,function(x) paste(sample_folder,"\\", x,sep = ""))
df.list <- lapply(temp, function(x) read.csv(x, header = TRUE, check.names = FALSE))
names(df.list) = tools::file_path_sans_ext(list.files(pattern="*.csv", path = sample_folder))

temp2 = list.files(pattern="*csv", path = scale_folder)
temp2 = lapply(temp2,function(x) paste(scale_folder,"\\", x,sep = ""))
scale_df.list <- lapply(temp2, function(x) read.csv(x, header = TRUE, check.names = FALSE))
names(scale_df.list) = tools::file_path_sans_ext(list.files(pattern="*.csv", path = scale_folder))



##################################################################################################
# first, we transform the scale values to channel values and then we
# add the sampleID as a column to each member of df.list 
#to convert from scale to channel we use log base (1.01611) and any negative
# number becomes 0
transform_dataframe <- function(dataframe) 
{
  transformed_df = dataframe
  for (i in  1:length(dataframe))
  {
    current_df = dataframe[[i]]
    dataframe[[i]] = cbind( dataframe[[i]], names(dataframe)[i] )
    transformed_df[[i]] = cbind( current_df, names(dataframe)[i] )
    names(dataframe[[i]])[length(names(dataframe[[i]]))] = "sample_id"
    names(transformed_df[[i]])[length(names(dataframe[[i]]))] = "sample_id"
  }
  dataframe = bind_rows(dataframe)
  transformed_df = bind_rows(transformed_df)
  return( list(dataframe, transformed_df) )
}


temporal = transform_dataframe(scale_df.list)
sample_names = names(scale_df.list)
original.df= temporal[[1]]
rm(scale_df.list)

temporal = transform_dataframe(df.list)
transformed.df = temporal[[2]]

rm(df.list)
rm(temporal)

print("finished transforming dataframes")

#Here we go through the positive populations and calculate their standard deviation
#Then, we go to the transformed list and subtract the minimum number found
#in the positive populations and  divide the resulting number by the standard 
#deviation
bug_report = paste("these are the markers:  ", unique_markers)
print(bug_report)

for(i in unique_markers)
{
  print(paste("loading  " , i))
  temp = list.files(pattern=i, path = positive_pop_folder, ignore.case = TRUE)
  temp = lapply(temp,function(x) paste(positive_pop_folder,"\\", x,sep = ""))
  if (length(temp) < 1)
  {
    marker_plus_a = paste(i,"-A", sep = "")
    temp = list.files(pattern=marker_plus_a, path = positive_pop_folder, ignore.case = TRUE)
    temp = lapply(temp,function(x) paste(positive_pop_folder,"\\", x,sep = ""))
  }
  positive.list <- lapply(temp, read_csv, col_select = i, show_col_types = FALSE)
  positive.list = bind_rows(positive.list)
  positive.list = positive.list[[i]]
  for ( k in 1:length( positive.list) )
  {
    if ( !is.finite(positive.list[k]) )
    {
      positive.list[k] = 0
    }
  }
  marker_name = i
  if (  !(i %in% names(transformed.df))  )
  {
    marker_name = paste(i,"-A", sep = "")
  }
  #marker_name = gsub("-", ".", i)
  current_minimum = min(positive.list)
  current_sd = sd(positive.list)
  current_mean = mean(transformed.df[[marker_name]])
  #current_sd = sd(transformed.df[[marker_name]])
  #when importing csv tables, the names replace "-" for "." so here we have to deal with that
  transformed.df[[marker_name]] = sapply(transformed.df[[marker_name]], function(x) max((x-current_minimum)/current_sd, 0))
  
  #transformed.df[[marker_name]] / current_sd
  
  print(paste("no problems with marker  " , i))
}

print("finished calculating z.scales")

#Here we just iterate through the markers found in the excel file with the pathways
#add them up and bind them to the original dataframe so that when we export it
#you can see them alongside all the other fluorophores
markers_repeated = length(row.names(parameter_names))

average_distances = data.frame(matrix(ncol = length(unique_pathways) + 1, nrow = length(sample_names)))
colnames(average_distances) = c("sample", unique_pathways)
average_distances["sample"] = sample_names
for (i in unique_pathways)
{
  print(paste("calculating ", i))
  enrichment = replicate(length(row.names(transformed.df)), 0)
  center_of_current_pathway = replicate(length(sample_names), {})
  names(center_of_current_pathway) = sample_names
  for (j in 1:markers_repeated)
  {
    pathway_name = parameter_names$pathway[j]
    if (pathway_name == i)
    {
      marker_name = parameter_names$marker[j]
      for (sample_name in sample_names)
      {
        mean_for_marker = mean(transformed.df[[marker_name]][transformed.df$sample_id == sample_name])
        center_of_current_pathway[[sample_name]][marker_name] = mean_for_marker
      }
      #when importing csv tables, the names replace "-" for "." so here we have to deal with that
      #marker_name = gsub("-", ".", marker_name)
      for ( k in 1:length(transformed.df[[marker_name]]) )
      {
        enrichment[k] = enrichment[k] + transformed.df[[marker_name]]  [k]
      }
    }
  }
  
  ###########################################
  #####TO-DO: we already calculated the centers of each pathway for each sample
  ##but we still need to calculate the average distance and add it to the 
  ##average_distances dataframe
  #####################################################
  distances_dictionary = {}
  for (sample_name in sample_names)
  {
    distances_dictionary[sample_name] = 0
    marker_values = transformed.df[transformed.df["sample_id"] == sample_name,]
    for (cell in (1:length(marker_values[[1]])))
    {
      current_distance = 0
      for (marker in names(center_of_current_pathway[[1]]))
      {
        squared_distance = (marker_values[[marker]][cell] - center_of_current_pathway[[sample_name]][marker]) ** 2
        current_distance = current_distance + squared_distance
      }
      distances_dictionary[sample_name] = distances_dictionary[sample_name] + sqrt(current_distance)
    }
    distances_dictionary[sample_name] = distances_dictionary[sample_name] / length(marker_values[[1]])
    average_distances[average_distances["sample"] == sample_name,][i] = distances_dictionary[sample_name]
  }
  
  
  original.df = cbind(original.df, enrichment * 100)
  names(original.df)[length(names(original.df))] = i
  
  
  transformed.df = cbind(transformed.df, enrichment)
  names(transformed.df)[length(names(transformed.df))] = i
  print(paste("finished ", i))
}

print("finished binding the cumulative scores to the scale values")

#Here we are just splitting the original dataframe to save the samples individually
split_df <- split(original.df, original.df$sample_id)
for (i in names(split_df))
{
  file_name = paste(results_folder, "\\", i, ".csv", sep = "")
  write.csv(split_df[[i]], file = file_name, row.names = FALSE)
}

file_name = paste(results_folder, "\\", "concatenated.csv", sep = "")
write.csv(original.df, file = file_name, row.names = FALSE)

file_name_diversity = paste(results_folder, "\\", "diversity.csv", sep = "")
write.csv(average_distances, file = file_name_diversity, row.names = FALSE)

print("finished printing results. Calculating correlation matrix")

############################################################################
#The rest of the script is just calculating the correlation matrix
empty_column = as.data.frame(numeric(nrow(transformed.df)))

for (i in names(transformed.df))
{
  empty_column = cbind(empty_column, transformed.df[[i]])
  names(empty_column)[length(names(empty_column))] = i
}
empty_column = empty_column[2:length(empty_column)]
corr_matrix = rcorr(as.matrix(empty_column), type = "pearson")

pvalue_threshold = .0000001
basesize = 15
title = "correlation matrix"

r = reshape2::melt(corr_matrix$r)
p = reshape2::melt(corr_matrix$P)
p = cbind(p,r[3])
#adds the interactable layer
texter <- function(df){
  paste("x: ", df[2], "\n", "y: ", df[1], "\n", "pvalue: ",df[3], "\n", "coeff", df[4])
}
p = cbind(p,apply(p,1,texter))
names(p) = c("Var1", "Var2", "pvalue", "coeff", "text")
#sets all pvalues above the threshold to the threshold to improve clarity
p$pvalue[p$pvalue > pvalue_threshold] <- pvalue_threshold
c = ggplot(p, aes(x = Var2, y = Var1, text = text)) + geom_tile(aes(fill = coeff), colour = "white")+ scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0, space = "Lab")
c = c +  geom_text(aes(label = round(coeff,2)), size = basesize/10)
c = c + theme_grey(base_size=basesize/2)
c = c + labs(x="", y="")
c = c + scale_x_discrete(expand = c(0,0))
c = c + theme(axis.ticks=element_blank(), axis.text.x=element_text(size=basesize/2, angle=330, hjust = 0, colour="grey50"))
c = c + ggtitle(title)
plot_file = paste(results_folder, "/corr_matrix.jpg", sep = "")
ggsave(filename=plot_file, plot=c, width = 4096, height = 4096, units = "px")
ggplotly(c, tooltip = "text")

