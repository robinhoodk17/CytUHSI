library(Hmisc)
library(ggplot2)
library(readxl)
library(reshape2)
library(plyr)
library(scales)
library(mice)
library(tcltk)

filters = matrix(c("xls", "xlsx"), 1, 2)
#PLease enter here the name of the file with the control samples (remember to change all \ characters)
WT_file = tk_choose.files(caption = "Select your WT file. It must be an excel file", multi = FALSE, filters = filters)


#PLease enter here the name of the file with the treated samples (remember to change all \ characters)
Treat_file = tk_choose.files(caption = "Select your treated file. It must be an excel file", multi = FALSE, filters = filters)


#PLease enter here the name of the folder where you wish to save the plots (remember to change all \ characters)
Plot_folder = tk_choose.dir(caption = "Select the folder to store your results")









WT_data = read_excel(WT_file)
Treat_data = read_excel(Treat_file)

WT_data = WT_data[2:length(WT_data)]
Treat_data = Treat_data[2:length(Treat_data)]
#WT_data = complete(mice(complete(mice(WT_data))))
#Treat_data = complete(mice(complete(mice(Treat_data))))


#########   Correlation matrices    ############
#getting the correlation matrices
WT_corr_matrix = rcorr(as.matrix(WT_data))
Treat_corr_matrix = rcorr(as.matrix(Treat_data))
#formatting the correlation matrices for graphing
WT_r = melt(WT_corr_matrix$r)
WT_p = melt(WT_corr_matrix$P)
WT_r = ddply(WT_r, .(Var2), transform, value = value)
WT_p = ddply(WT_p, .(Var2), transform, value = value)
Treat_r = melt(Treat_corr_matrix$r)
Treat_p = melt(Treat_corr_matrix$P)
Treat_r = ddply(Treat_r, .(Var2), transform, value = value)
Treat_p = ddply(Treat_p, .(Var2), transform, value = value)
#graphing the WT corr matrix (p) and Treatment matrix (q)
base_size = 15
(p = ggplot(WT_p, aes(Var2, Var1)) + geom_tile(aes(fill = value), colour = "white")+ scale_fill_gradient(low = c("red", "darkgoldenrod1","darkgoldenrod2","darkgoldenrod3", "darkgoldenrod4"), high = c("white"), space = "Lab") + geom_text(data = WT_r, aes(label = round(value,2)), size = 4.5) )
p <- p + theme_grey(base_size=base_size)
p <- p + labs(x="", y="")
p <- p + scale_x_discrete(expand = c(0,0))
p <- p + theme(axis.ticks=element_blank(), axis.text.x=element_text(size=base_size, angle=330, hjust = 0, colour="grey50"))
p = p + ggtitle("Wild type correlation matrix")
p

filename = paste(Plot_folder,"/WT_corr_matrix.jpeg", sep = "")
jpeg(filename = filename, width = 1080, height = 1080, quality = 200)
p
dev.off()

(q = ggplot(Treat_p, aes(Var2, Var1)) + geom_tile(aes(fill = value), colour = "white")+ scale_fill_gradient(low = c("red", "darkgoldenrod1","darkgoldenrod2","darkgoldenrod3", "darkgoldenrod4"), high = c("white"), space = "Lab") + geom_text(data = Treat_r, aes(label = round(value,2)), size = 4.5) )
q = q + theme_grey(base_size=base_size)
q = q + labs(x="", y="")
q = q + scale_x_discrete(expand = c(0,0))
q = q + theme(axis.ticks=element_blank(), axis.text.x=element_text(size=base_size, angle=330, hjust = 0, colour="grey50"))
q = q + ggtitle("Treatment correlation matrix")
q

filename = paste(Plot_folder,"/Treated_corr_matrix.jpeg", sep = "")
jpeg(filename = filename, width = 1080, height = 1080, quality = 200)
q
dev.off()

#########   Correlation comparison    ############
#creating the function to get the p-value between two correlations
blabla = function(x1, x2, y1, y2, method="pearson") {
  cor1 = cor.test(x1, x2, method=method)
  cor2 = cor.test(y1, y2, method=method)
  
  r1 = cor1$estimate
  r2 = cor2$estimate
  n1 = sum(complete.cases(x1, x2))
  n2 = sum(complete.cases(y1, y2))
  fisher = ((0.5*log((1+r1)/(1-r1)))-(0.5*log((1+r2)/(1-r2))))/((1/(n1-3))+(1/(n2-3)))^0.5
  
  p.value = (2*(1-pnorm(abs(fisher))))
  
  result= list(
    "cor1" = list(
      "estimate" = as.numeric(cor1$estimate),
      "p.value" = cor1$p.value,
      "n" = n1
    ),
    "cor2" = list(
      "estimate" = as.numeric(cor2$estimate),
      "p.value" = cor2$p.value,
      "n" = n2
    ),
    "p.value.twosided" = as.numeric(p.value),
    "p.value.onesided" = as.numeric(p.value) / 2
  )
  cat(paste(sep="",
            "cor1: r=", format(result$cor1$estimate, digits=3), ", p=", format(result$cor1$p.value, digits=3), ", n=", result$cor1$n, "\n",
            "cor2: r=", format(result$cor2$estimate, digits=3), ", p=", format(result$cor2$p.value, digits=3), ", n=", result$cor2$n, "\n",
            "diffence: p(one-sided)=", format(result$p.value.onesided, digits=3), ", p(two-sided)=", format(result$p.value.twosided, digits=3), "\n"
  ))
  return(result);
}
#actually getting the p-value for the difference between the correlations. Since the matrix for the correlation was created using
#WT_r, the p-values do not need formatting
comparison = WT_r
comparison[3] = WT_r[3] - Treat_r[3]
comparison_colors = comparison
counter = 1
for (i in 1:length(WT_data)) {
  for (j in 1:length(WT_data)) {
    comparison_colors[counter, 3] = blabla(WT_data[[j]], WT_data[[i]], Treat_data[[j]], Treat_data[[i]])$p.value.twosided
    counter = counter + 1
  }
}
#graphing the comparison of the correlations
base_size = 15
(s = ggplot(comparison_colors, aes(Var2, Var1)) + geom_tile(aes(fill = value), colour = "white")+ scale_fill_gradient(low = c("red", "darkgoldenrod1","darkgoldenrod2","darkgoldenrod3", "darkgoldenrod4"), high = c("white"), space = "Lab") + geom_text(data = comparison, aes(label = round(value,2)), size = 4.5) )
s <- s + theme_grey(base_size=base_size)
s <- s + labs(x="", y="")
s <- s + scale_x_discrete(expand = c(0,0))
s <- s + theme(axis.ticks=element_blank(), axis.text.x=element_text(size=base_size, angle=330, hjust = 0, colour="grey50"))
s = s + ggtitle("comparison correlation matrix")
s

plotly::ggplotly(s)

filename = paste(Plot_folder,"/comparison.jpeg", sep = "")
#ggsave(filename=filename, plot=s, width = 4096, height = 4096, units = "px")
jpeg(filename = filename, width = 1080, height = 1080, quality = 200)
s
dev.off()
