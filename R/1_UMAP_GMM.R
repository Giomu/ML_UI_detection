################################################################################
########### First Analysis: Dimensionality Reduction and Clustering ############
################################################################################
# This script performs dimensionality reduction and clustering on synthetic data. 
# The dataset contains 116 observations and 13 variables, generated based on real data. 
# We compare two methods for dimensionality reduction: UMAP and t-SNE.
# After reducing the dimensionality, we apply Gaussian Mixture Models (GMM) 
# for clustering and evaluate the clustering results using:
#  - Within-cluster sum of squares (WSS) 
#  - Average silhouette width
# 
# The script produces visualizations for both UMAP and t-SNE projections, 
# as well as clustering results.
################################################################################

set.seed(983)
# Load the necessary libraries
library(mclust)
library(ggplot2)

# Load synthetic data
data(synth1)
head(synth1)

##############################
# Dimensionality Reduction: UMAP
##############################
set.seed(289) 
# Apply UMAP on the dataset, excluding the first column (assumed to be Infectious status)
um <- umap::umap(synth1[,-c(1)], method = 'umap-learn', preserve.seed = T)

# Convert UMAP results into a data frame
umap_df <- data.frame(um$layout)
umap_df$Group <- synth1$Infection_0_1pre_2post
umap_df$ID <- rownames(umap_df) 

# Plot UMAP projection
ggplot(umap_df, aes(x = X1, y = X2, color = Group)) + 
  geom_point(size = 3) +
  scale_color_manual(labels = c("No Infection", "Infection pre-boost", 
                                "Infection post-boost"),
                     values = c("#66a182", "#2e4057", "#edae49")) +
  labs(x = 'UMAP 1', y = 'UMAP 2', title = 'Dimensionality Reduction (UMAP)') +
  theme_minimal()

# Clustering with Gaussian Mixture Model (GMM) on UMAP-reduced data (unsupervised)
um_gmm = mclust::Mclust(umap_df[, c(1, 2)]) 

# Print summary of clustering results
summary(um_gmm)
# Plot the clustering results
plot(um_gmm, "classification") 
plot(um_gmm, "density")


##############################
# Dimensionality Reduction: t-SNE
##############################
set.seed(7567)
# Apply t-SNE on the dataset, excluding the first column (assumed to be Infectious status)
tsne <- Rtsne::Rtsne(synth1[, -c(1)], perplexity = 38, normalize=FALSE, theta = 0.5)

# Convert t-SNE results into a data frame
tsne_df <- data.frame(tsne$Y)
tsne_df$Group <- synth1$Infection_0_1pre_2post
tsne_df$ID <- rownames(tsne_df)

# Plot t-SNE projection
ggplot(tsne_df, aes(x = X1, y = X2, color = Group)) +
  geom_point(size = 3) +
  scale_color_manual(labels = c("No Infection", "Infection pre-boost", 
                                "Infection post-boost"),
                     values = c("#66a182", "#2e4057", "#edae49")) +
  labs(x = 't-SNE 1', y = 't-SNE 2', title = 'Dimensionality Reduction (t-SNE)') +
  theme_minimal()

# Clustering with Gaussian Mixture Model (GMM) on t-SNE-reduced data (unsupervised)
t_gmm <- mclust::Mclust(tsne_df[, c(1, 2)])

# Print summary of clustering results
summary(t_gmm)
# Plot the clustering results
plot(t_gmm, "classification")
plot(t_gmm, "density")


##############################
# Clustering Performance Evaluation
##############################
# Compute clustering statistics for UMAP-based clustering
cs_um_gmm <- fpc::cluster.stats(dist(umap_df[1:2]), um_gmm$classification)
stats_um_gmm <- cs_um_gmm[c("within.cluster.ss","avg.silwidth")]

# Compute clustering statistics for t-SNE-based clustering
cs_ts_gmm <- fpc::cluster.stats(dist(tsne_df[1:2]), t_gmm$classification)
stats_t_gmm <- cs_ts_gmm[c("within.cluster.ss","avg.silwidth")]

# Combine statistics and print Comparison
stats <- rbind(stats_um_gmm, stats_t_gmm)
rownames(stats) <- c("UMAP", "t-SNE")
stats <- as.data.frame(stats)
stats
