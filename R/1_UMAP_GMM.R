################################################################################
########### First Analysis: Dimensionality Reduction and Clustering ############
################################################################################
# This script is the first part of the analysis. It performs dimensionality
# reduction and clustering on the synthetic data. The data is generated from
# real data and contains 116 observations and 13 variables. The script compares
# UMAP and t-SNE for dimensionality reduction and then applies Gaussian Mixture 
# Models for clustering.

# Load the necessary libraries
library(mclust)
library(ggplot2)

# Load the data for the first analysis part
data(synth1)
head(synth1)

# 1. Dimensionality Reduction with UMAP
set.seed(983)
set.seed(289) 
# UMAP computation
um <- umap::umap(synth1[,-c(1)], method = 'umap-learn', preserve.seed = T)

# UMAP plot
umap_df <- data.frame(um$layout)
umap_df$Group <- synth1$Infection_0_1pre_2post
umap_df$ID <- rownames(umap_df) 

ggplot(umap_df, aes(x = X1, y = X2, color = Group)) + 
  geom_point(size = 3) +
  scale_color_manual(labels = c("No Infection", "Infection pre-boost", 
                                "Infection post-boost"),
                     values = c("#66a182", "#2e4057", "#edae49")) +
  labs(x = 'UMAP 1', y = 'UMAP 2', title = 'Dimensionality Reduction (UMAP)') +
  theme_minimal()


# UMAP cluster using gmm from mclust library (unsupervised)
um_gmm = mclust::Mclust(umap_df[, c(1, 2)]) 
# Print summary of clustering results
summary(um_gmm)
# Plot the clustering results
plot(um_gmm, "classification") 
plot(um_gmm, "density")
plot(um_gmm, "BIC")


# 2. Dimensionality Reduction with t-SNE
set.seed(7567)
# t-SNE computation
tsne <- Rtsne::Rtsne(synth1[, -c(1)], perplexity = 38, normalize=FALSE, theta = 0.5)

# t-SNE plot
tsne_df <- data.frame(tsne$Y)
tsne_df$Group <- synth1$Infection_0_1pre_2post
tsne_df$ID <- rownames(tsne_df)

ggplot(tsne_df, aes(x = X1, y = X2, color = Group)) +
  geom_point(size = 3) +
  scale_color_manual(labels = c("No Infection", "Infection pre-boost", 
                                "Infection post-boost"),
                     values = c("#66a182", "#2e4057", "#edae49")) +
  labs(x = 't-SNE 1', y = 't-SNE 2', title = 'Dimensionality Reduction (t-SNE)') +
  theme_minimal()

# t-SNE cluster using gmm from mclust library (unsupervised)
t_gmm <- mclust::Mclust(tsne_df[, c(1, 2)])
# Print summary of clustering results
summary(t_gmm)
# Plot the clustering results
plot(t_gmm, "classification")
plot(t_gmm, "density")
plot(t_gmm, "BIC")


# 3. Comparison in terms of within.cluster.ss and avg.silwidth
# UMAP
cs_um_gmm <- fpc::cluster.stats(dist(umap_df[1:2]), um_gmm$classification)
stats_um_gmm <- cs_um_gmm[c("within.cluster.ss","avg.silwidth")]
# t-SNE
cs_ts_gmm <- fpc::cluster.stats(dist(tsne_df[1:2]), t_gmm$classification)
stats_t_gmm <- cs_ts_gmm[c("within.cluster.ss","avg.silwidth")]
# Print Comparison
stats <- rbind(stats_um_gmm, stats_t_gmm)
rownames(stats) <- c("UMAP", "t-SNE")
stats <- as.data.frame(stats)
stats











