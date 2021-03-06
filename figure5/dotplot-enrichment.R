### installing packages

library(reshape2)
library(scales)
library(ggplot2)


### setting working directory

setwd("../data/")

### enrichment enhancer stratified all clusters

### plots of timecourse data against all consensus

clustervector <- c("cluster1","cluster2","cluster3","cluster4","cluster5","cluster6","cluster7","cluster8","cluster9","cluster10","cluster11")

### making lists

list_df_p <- list()

list_df_or <- list()

### starting loop

for (element in clustervector){
  
  ### reading in data
  
  cluster = element
  
  print(cluster)
  
  data = read.table(paste("all_consensus/",cluster,"/col_HAP1_specific.tsv",sep = ""),header = T)
  
  data_sorted <- data[order(data$filename),]
  
  list_df_p[[cluster]] = data_sorted$pValueLog
  
  list_df_or[[cluster]] = data_sorted$oddsRatio
  
}

### making plot table

dataframe_p <- data.frame(list_df_p)

dataframe_p$feature <- gsub(".bed","",data_sorted$filename)

row.names(dataframe_p) <- dataframe_p$feature

dataframe_p_woBAF <- dataframe_p[c("Enh","EnhAct","EnhBiv","EnhGen","EnhSup","EnhWeak"),]

dataframe_or <- data.frame(list_df_or)

dataframe_or$feature <- gsub(".bed","",data_sorted$filename)

row.names(dataframe_or) <- dataframe_or$feature

dataframe_or_woBAF <- dataframe_or[c("Enh","EnhAct","EnhBiv","EnhGen","EnhSup","EnhWeak"),]

dataframe_p_reshaped <- melt(dataframe_p_woBAF, id="feature")

dataframe_p_reshaped$value <- as.numeric(gsub(Inf,1000,dataframe_p_reshaped$value))

dataframe_or_reshaped <- melt(dataframe_or_woBAF, id="feature")

dataframe_p_or_reshaped_merge <- cbind(dataframe_p_reshaped,dataframe_or_reshaped)

colnames(dataframe_p_or_reshaped_merge) <- c("feature_p","cluster_p","neg_log10_p_value","feature_or","cluster_or","or")

### making plot

dataframe_p_or_reshaped_merge$feature_p <- factor(dataframe_p_or_reshaped_merge$feature_p, levels = c("Enh","EnhAct","EnhBiv","EnhGen","EnhSup","EnhWeak"))

dataframe_p_or_reshaped_merge$neg_log10_p_value_new <- ifelse(dataframe_p_or_reshaped_merge$neg_log10_p_value < 1.3, NA,dataframe_p_or_reshaped_merge$neg_log10_p_value)


cols <- c("deepskyblue",
          "red")


dotplot = ggplot(dataframe_p_or_reshaped_merge) +
  geom_point(mapping = aes(x= cluster_p, y=feature_p, size=or, colour = neg_log10_p_value_new)) +
  scale_colour_gradientn(colours = cols, breaks=c(0,10,20), limits = c(0,20),oob=squish,na.value = 'black') +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90))

pdf("dotplot-HAP1-enrichment-enhancers-all-clusters-against-all-consensus.pdf",useDingbats = F) 
print(dotplot)
dev.off()

