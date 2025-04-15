# Machine Learning Approaches to Dissect Hybrid and Vaccine-Induced Immunity

This repository contains the code associated with the paper titled "***Machine Learning Approaches to Dissect Hybrid and Vaccine-Induced Immunity***" authored by *G. Montesi, S. Costagli et al*.

## Overview

The project focuses on developing a Machine Learning pipeline designed to dissect and predict immune response profiles associated with SARS-CoV-2 infection and vaccination. The pipeline integrates both unsupervised and supervised learning approaches to characterize hybrid and vaccine-induced immunity.

In the unsupervised component (code in `1_UMAP_GMM.R`), the pipeline leverages dimensionality reduction techniques (UMAP and t-SNE) in combination with a Gaussian Mixture Model clustering algorithm to identify distinct immune response patterns based on 12 immunological variables (`synth1.rda`). This enables the discovery of latent subgroups within the data without prior knowledge of infection or vaccination status.

In the supervised component (code in `2_UI_detection.R`), we implement a suite of classification algorithms (k-Nearest Neighbors, Support Vector Machines with Radial Basis Function kernel and Random Forest) to distinguish between profiles of hybrid immunity (i.e., vaccine plus prior infection) and vaccine-induced-only immunity using a labelled synthetic dataset (`synth2.rda`). The trained models are subsequently applied to an unlabelled dataset (`synth3.rda`) to infer individuals with potential prior unrecognized infection—referred to as *unaware infected*—based solely on their immunological signatures.

This repository provides the full implementation of the analysis presented in the manuscript, including all code, synthetic datasets, and detailed instructions for reproducing the results.

## Repository Structure

-   `data/`: Contains the synthetic datasets used for training and evaluation.

    ```{bash}
    data/
    ├── synth1.rda # Synthetic dataset used for the unsupervised analysis
    ├── synth2.rda # Labelled dataset used for training and evaluating classifiers 
    ├── synth3.rda # Unlabelled dataset used for prediction of UI individuals
    ```

-   `notebooks/`: notebook showing the entire Machine Learning pipeline proposed in the manuscript applied to synthetic datasets.

    ```{bash}
    notebooks/
    ├── ML_analysis.Rmd  # Markdown notebook 
    ├── ML_analysis.html # notebooks HTML version
    ```

-   `R/`: This folder contains core R scripts implementing the main analytical components of the pipeline.

    ```{bash}
    R/
    ├── 1_UMAP_GMM.R     # Implements UMAP/t-SNE embeddings and GMM-based clustering for unsupervised immune profiling
    ├── 2_UI_detection.R # Trains and evaluates classifiers, performs variable importance analysis, and predicts unaware infections
    ```

-   `LICENSE`: The MIT License under which this project is released.

-   `ML_UI_detection.Rproj`: R project file to facilitate environment setup and execution.

## Synthetic Data

Please note that the datasets included in this repository are fully synthetic and were generated solely for the purpose of demonstrating the analytical workflow of the Manuscript. These datasets do not reflect the real patient data used in the study and do not contain any sensitive or personally identifiable information.

Due to ethical considerations and data privacy regulations, the original clinical and immunological datasets cannot be shared publicly, however data here reported allow users to understand and replicate the methodology without accessing proprietary information.

## Getting Started

To reproduce the analyses presented in the manuscript and run the pipeline locally, please follow the steps below:

1.  **Install R**

    Download and install the latest version of R from the Comprehensive R Archive Network (CRAN): [https://cran.r-project.org](#0) .

2.  **Install RStudio (Recommended IDE)**

    Download and install RStudio, a powerful and user-friendly IDE for R: <https://posit.co/download/rstudio-desktop/> .

3.  **Clone the Repository**

    You can clone this repository using Git from the command line:

    ```{bash}
    git clone https://github.com/Giomu/ML_UI_detection.git
    ```

    Alternatively, you can download the ZIP archive directly from GitHub and extract it.

4.  **Open the Project in RStudio**

    Open the `ML_UI_detection.Rproj` file in RStudio. This will automatically load the project environment and working directory.

5.  **Install Required Packages**

    The pipeline relies on several R packages for dimensionality reduction, clustering, and classification. You can install them by running in your R Console:

    ```{r}
    install.packages(c("mclust", 
                       "umap", 
                       "Rtsne", 
                       "ggplot2", 
                       "fpc", 
                       "caret", 
                       "dplyr", 
                       "MLmetrics"))
    ```

    For proper installation and usage of these packages, please refer to the official documentation of each library, as system-specific dependencies or configuration steps may apply.

6.  **Run the Analysis**

    -   To reproduce the unsupervised immune profiling via UMAP/t-SNE + GMM, run `R/1_UMAP_GMM.R`

    -   To reproduce the supervised classification and unaware infection detection, run `R/2_UI_detection.R`

    -   Alternatively, you can explore the full pipeline interactively via the notebook in the `notebooks/` folder.

Detailed instructions on how to use the code, including examples, are provided within the notebook in the `notebooks/` directory. The notebook walk through the entire process from data loading to model evaluation.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
