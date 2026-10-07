
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
  install.packages("tcltk")
})

filters = matrix(c("xls", "xlsx"), 1, 2)

wt_steady_file <- tk_choose.files(caption = "choose  your WT at STEADY STATE. It should be an excel file", multi = FALSE, filters = filters)
ko_steady_file <- tk_choose.files(caption = "choose your KO at STEADY STATE. It should be an excel file", multi = FALSE, filters = filters)
wt_treated_file <- tk_choose.files(caption = "choose your WT AFTER TREATMENt. It should be an excel file", multi = FALSE, filters = filters)
ko_treated_file <- tk_choose.files(caption = "choose  your KO AFTER TREATMENT. It should be an excel file", multi = FALSE, filters = filters)


correlation_method = "pearson"

wt_steady_raw = read.xlsx(wt_steady_file, sheet = 1)
ko_steady_raw = read.xlsx(ko_steady_file, sheet = 1)
wt_treated_raw = read.xlsx(wt_treated_file, sheet = 1)
ko_treated_raw = read.xlsx(ko_treated_file, sheet = 1)

wt_steady_fold_change = data.frame(wt_steady_raw[1,])
ko_steady_fold_change = data.frame(ko_steady_raw[1,])
wt_treated_fold_change = data.frame(wt_treated_raw[1,])
ko_treated_fold_change = data.frame(ko_treated_raw[1,])

for( i in 2:length(names(wt_steady_raw))){
  parameter = names(wt_steady_raw)[i]
  mean_wt_steady = mean(wt_steady_raw[[parameter]])
  mean_ko_steady = mean(ko_steady_raw[[parameter]])
  mean_wt_treated = mean(wt_treated_raw[[parameter]])
  mean_ko_treated = mean(ko_treated_raw[[parameter]])
  
  wt_steady_fold_change[[parameter]] = 0
  ko_steady_fold_change[[parameter]] = (mean_ko_steady/mean_wt_steady) - 1
  wt_treated_fold_change[[parameter]] = 0
  ko_treated_fold_change[[parameter]] = (mean_ko_treated/mean_wt_treated) - 1
  
}



calculate_correlation_matrix <- function(regex_string_for_population, graphtitle)
{
  temp = list.files(pattern=regex_string_for_population, path = sample_folder)
  temp = lapply(temp,function(x) paste(sample_folder,"\\", x,sep = ""))
  df.list <- lapply(temp, read.csv)
  names(df.list) = tools::file_path_sans_ext(list.files(pattern=regex_string_for_population, path = sample_folder))
  
  
  bind_dataframes <- function(dataframe) 
  {
    transformed.df = dataframe[[1]]
    for (pattern in string_factors)
    {
      if (grepl(pattern, names(dataframe)[1] ) )
      {
        transformed.df = cbind(transformed.df, pattern)
      }
    }
    
    
    for (i in  2:length(dataframe))
    {
      current_df = dataframe[[i]]
      for (pattern in string_factors)
      {
        if (grepl(pattern, names(dataframe)[i]))
        {
          current_df = cbind(current_df, pattern)
        }
      }
      transformed.df = rbind(transformed.df, current_df)
    }
    return( transformed.df )
  }
  
  transformed.df = bind_dataframes(df.list)
  new_names = c()
  for (name in names(transformed.df))
  {
    if (name == "pattern")
    {
      new_names = c(new_names, "pattern")
    }
    else
    {
      new_names = c(new_names,strsplit(name, "\\.")[[1]][2])
    }
  }
  names(transformed.df) = new_names
  ############################################################################
  #The rest of the script is just calculating the correlation matrix
  resulting_corrs <- data.frame(matrix(ncol = length(string_factors) + 1, nrow = 0))
  colnames(resulting_corrs) = c(string_factors, "gene")
  
  for (protein in names(transformed.df))
  {
    if ((protein != endoglin)&(protein != "pattern"))
    {
      correlations = data.frame(matrix(rep(0, length(string_factors) + 1), nrow = 1))
      names(correlations) = c(string_factors, "gene")
      correlations$gene = protein
      for (string_factor in string_factors)
      {
        protein_data = transformed.df[[protein]]  [transformed.df$pattern == string_factor]
        endoglin_data = transformed.df[[endoglin]] [transformed.df$pattern == string_factor]
        correlation_index = cor.test(protein_data, endoglin_data, method = correlation_method)$estimate
        correlations[string_factor] = correlation_index
      }
      resulting_corrs = rbind(resulting_corrs, correlations)
    }
  }
  
  
  molten_corrs = reshape2::melt(resulting_corrs)
  
  
  basesize = 15
  title = graphtitle
  c = ggplot(molten_corrs, aes(x = variable, y = gene)) + geom_tile(aes(fill = value), colour = "white")+ scale_fill_gradient2(low = "red", mid = "white", high = "green", midpoint = 0, space = "Lab")
  c = c +  geom_text(aes(label = round(value,2)), size = basesize/10)
  c = c + theme_grey(base_size=basesize/2)
  c = c + labs(x="", y="")
  c = c + scale_x_discrete(expand = c(0,0))
  c = c + theme(axis.ticks=element_blank(), axis.text.x=element_text(size=basesize/2, angle=330, hjust = 0, colour="grey50"))
  c = c + ggtitle(title)
  print(ggplotly(c, tooltip = "text"))
  return(resulting_corrs)
  
}

wt_corrs = calculate_correlation_matrix(regex_string_for_WT, "WT")
ko_corrs = calculate_correlation_matrix(regex_string_for_KO, "KO")


total = cbind(wt_corrs, ko_corrs)
names(total)[4] = paste(string_factors[1],"ko", sep = "")
names(total)[5] = paste(string_factors[2],"ko", sep = "")
names(total)[6] = "drop"
total = total[, !(names(total) == "drop")]








ggplot(total, aes(x = reorder(gene, -.data[[string_factors[1]]]), y = .data[[string_factors[1]]])) + geom_bar(stat = "identity", fill = "lightpink1") + 
  coord_flip() + 
  ylim(-.25, .75) + 
  theme_classic(base_size = 15) + 
  labs(x = "pathway", y = paste("correlation with ", endoglin, " expression", sep = "")) +
  ggtitle("WT")

ggplot(total, aes(x = reorder(gene, -.data[[string_factors[1]]]), y = .data[[string_factors[2]]])) + geom_bar(stat = "identity", fill = "slategray3") + 
  coord_flip() + 
  ylim(-.25, .75) + 
  theme_classic(base_size = 15) + 
  labs(x = "pathway", y = paste("correlation with ", endoglin, " expression", sep = "")) +
  ggtitle("WT")

ggplot(total, aes(x = reorder(gene, -.data[[string_factors[1]]]), y = .data[[names(total)[4]]])) + geom_bar(stat = "identity", fill = "lightpink1") + 
  coord_flip() + 
  ylim(-.25, .75) + 
  theme_classic(base_size = 15) + 
  labs(x = "pathway", y = paste("correlation with ", endoglin, " expression", sep = "")) +
  ggtitle("KO")

ggplot(total, aes(x = reorder(gene, -.data[[string_factors[1]]]), y = .data[[names(total)[5]]])) + geom_bar(stat = "identity", fill = "slategray3") + 
  coord_flip() + 
  ylim(-.25, .75) + 
  theme_classic(base_size = 15) + 
  labs(x = "pathway", y = paste("correlation with ", endoglin, " expression", sep = "")) +
  ggtitle("KO")

comparison1 = paste(names(total)[1],"vs", names(total)[2], sep = " ")
comparison2 = paste(names(total)[1],"vs", names(total)[4], sep = " ")
comparison3 = paste(names(total)[2],"vs", names(total)[5], sep = " ")
comparison4 = paste(names(total)[4],"vs", names(total)[5], sep = " ")
cor_names = c(comparison1, comparison2, comparison3, comparison4)
results = as.data.frame(c(0,0,0,0), row.names = cor_names)
names(results) = "pvalue"
result1 = cor.test(total[[names(total)[1]]], total[[names(total)[2]]], method = "spearman")$p.value
result2 = cor.test(total[[names(total)[1]]], total[[names(total)[4]]], method = "spearman")$p.value
result3 = cor.test(total[[names(total)[2]]], total[[names(total)[5]]], method = "spearman")$p.value
result4 = cor.test(total[[names(total)[4]]], total[[names(total)[5]]], method = "spearman")$p.value
results[[1]][1] = result1
results[[1]][2] = result2
results[[1]][3] = result3
results[[1]][4] = result4
print(results)


