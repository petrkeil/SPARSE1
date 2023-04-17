# 5/2/2022 by Petr Keil

library("readxl")
library("rstudioapi")
library("dplyr")
library("sampling")
library("cluster")
library("tidyverse")

# set working directory to the current path (works in R studio)
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))

## IMPORTANT ##
# specify path to the original (un-ordered) data
orig.file <- "../../data/priority list of studies/SurveyOfMaterials-birds.xlsx"
# this is the file into which we will export the results
reordered.file <- "../../data/priority list of studies/reordered_study_list.csv"

# read the data table
X <- read_excel(orig.file, sheet = 1)
X <- data.frame(X)

# turn some columns to boolean variable
X$isProtectedArea <- X$isProtectedArea == "Y"
X$isProtectedArea[which(is.na(X$isProtectedArea))] <- FALSE

X$done <- X$done == "Y"
X$done[which(is.na(X$done))] <- FALSE

# studies have already been in the database
done.X <- X[X$done == TRUE, ]

# studies that have not yet been in the database
X <- X[X$done == FALSE, ]

# ------------------------------------------------------------------------------

## IMPORTANT ##
# select variables for clustering
cluster.vars <- select(.data = X, yearPublished, district, isProtectedArea) %>%
                mutate(district = as.factor(district), 
                       isProtectedArea = as.factor(isProtectedArea))

# pairwise dissimilarity matrix based 
dissim <- daisy(cluster.vars, metric="gower")

# partitioning around medoids (PAM)
k = 10 # set number of clusters
pam.clusters = pam(as.matrix(dissim),
                   diss = TRUE,
                   k = k)$clustering

# create a sequence of clusters, and sequence of increasing indices witihn 
# each cluster
clust.id <- sort(unique(pam.clusters))
clust.size <- as.numeric(table(as.factor(pam.clusters)))
clust.seq <- c()
for(i in 1:length(clust.id))
{
  seq.i <- seq(from = 1, to = clust.size[i])
  clust.seq <- c(clust.seq, seq.i)
}

# order studies based on the cluster sequence produced above; ties are resolved
# by a random draw
studyRank <- rank(clust.seq, ties.method = "random")

# order the dataset
X <- data.frame(X, studyRank)
X <- X[order(X$studyRank),]

# tidy things up by removing the rank column
X <- select(X, -studyRank)

# append the re-ordered data with the part of data that has already been in the 
# database
X <- rbind(done.X, X)

# export the file
write.csv(X, file=reordered.file, row.names=FALSE)
