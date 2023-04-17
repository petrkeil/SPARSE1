# install.packages("taxize")
# library(taxize)
# ?taxize - shows help

# ? shows help - in bottom of help click to index - list of all functions in package

# https://github.com/ropensci/taxize
# https://github.com/ropensci-archive/taxizesoap

# gnr_resolve - Resolve names using Global Names Resolver
# fce resolve - Resolve names from iPlant's name resolver, and the Global Names Resolver (GNR)
# fce synonyms - Retrieve synonyms from various sources given input taxonomic names or identifiers
# fce taxize_cite - Get citations and licenses for data sources used in taxize

# For those APIs that require authentication, the way that's typically done is through API keys: alphanumeric strings of variable lengths that are supplied with a request to an API.

# package tax_fix
# package taxonstand - just plants
# package U.taxonstand - plants and animals
# https://www.sciencedirect.com/science/article/pii/S2468265922000944
# package taxa
# https://f1000research.com/articles/7-272



# SOURCE OF TAXIZE WORKFLOW: http://viktoriawagner.weebly.com/blog/cleaning-species-names-with-r-ii-taxize


############## INSTALL TAXIZE AND HELPER PACKAGES ##############

# 1. Install taxize and helper packages dplyr and magrittr

# install libraries taxize, dplyr, magrittr (if not already done)
# dplyr is used for data manipulation
# magrittr is used to chain functions though pipes.

# install.packages("taxize")
# install.packages(c("dplyr", "magrittr"))

library(taxize)
library(dplyr)
library(magrittr) 

# WARNING message: package 'taxize' was built under R version 4.1.3

# ERROR: Attaching package: 'dplyr'
# The following objects are masked from 'package:stats': filter, lag
# The following objects are masked from 'package:base': intersect, setdiff, setequal, union
# SOLUTION: It's telling you that if you apply one of these functions it's going to refer to the dplyr function, not base-r or stats. 
# If you want to refer to the base-r or stats version, you can can specific the package with double colons. For example, check out,
# ?dplyr::filter
# ?stats::filter


# remove.packages("magrittr", "magrittr")

# install.packages("magrittr")

# library(magrittr) 


############## SET WORKING DIRECTORY ##############


# setwd('C:/Users/tschernosterova/OneDrive - CZU v Praze/SPARSE/experiments/queries')
# getwd()


############## READ DATA ##############


raw_species<-read.csv('speciesAccess.csv',header=T)
head(raw_species)

names(raw_species)[names(raw_species) == 'ï..verbatimIdentification'] <- 'verbatimIdentification'

head(raw_species)
str(raw_species)
summary(raw_species)



############## SPECIFY TAXONOMIC REFERENCE DATABASES ##############


gnr_data_sources <- gnr_datasources()

gnr_data_sources

write.csv(gnr_data_sources, "gnr_data_sources.csv")

# 94 different sources to match nameS against can be used 
# we can inspect the full list of available sources

# src <- c("EOL", "The International Plant Names Index","Index Fungorum", "ITIS", "Catalogue of Life")
# subset(gnr_datasources(), title %in% src)

# specify the reference databases you want to use 
# if databases are not indicated, GNR will match names against all sources

# USEFULL SOURCES:
# 1	- Catalogue of Life Checklist - update 22-09
# 3	- Integrated Taxonomic Information System ITIS - update 22-06
# 11	- GBIF Backbone Taxonomy - update 22-06
# 12	- Encyclopedia of Life - update 22-06
# 138	- Birds of the World: Recommended English Names - update 12-02 - too old
# 175	- BirdLife International - update 14-12 - too old
# 180	- iNaturalist - update 16-10 - too old
# 185	- IOC World Bird List - update 21-12
# 189 - The Howard and Moore Complete Checklist of the Birds of the World - update 20-05

# !!!!!!!! European bird atlas is using:
# HBW and BirdLife International Checklist of the Birds of the World del Hoyo 2014, 2016



############## RUN RESOLVER ##############


# Global Names Resolver (from EOL/GBIF)	gnr - USED ALL SOURCES - takes time to get results + too many of them (13.422 rows in example)
resolved_ALL <- gnr_resolve(raw_species$verbatimIdentification)

head(resolved_ALL)
summary(resolved_ALL)
write.csv(resolved_ALL, "speciesRresolvedALL.csv")


# just chosen data sources were used for resolving - more convenient (2707 rows in example)

resolved_SELECTED <- gnr_resolve(raw_species$verbatimIdentification, 
                                 data_source_ids = c(1,3,11,12,138,175, 180,185))

head(resolved_SELECTED)
summary(resolved_SELECTED)
write.csv(resolved_SELECTED, "speciesRresolvedSELECTED.csv")


# takes only the best match for each species (366 rows in example)
# in result - matched_name2 (character) - returned if canonical=TRUE, in which case matched_name is not returned

resolved_BEST_MATCH <- gnr_resolve(raw_species$verbatimIdentification, 
                                   data_source_ids = c(1,3,11,12,138,175, 180,185), 
                                   canonical = TRUE, 
                                   best_match_only = TRUE)

head(resolved_BEST_MATCH)
summary(resolved_BEST_MATCH)
write.csv(resolved_BEST_MATCH, "speciesRresolvedBESTMATCH.csv")


# GBIF - 11 - update 2022-06
# takes only the best match for each species (366 rows in example)
# in result - matched_name2 (character) - returned if canonical=TRUE, in which case matched_name is not returned

resolved_GBIF <- gnr_resolve(raw_species$verbatimIdentification, 
                             data_source_ids = c(1,3,11,12,138,185), 
                             canonical = TRUE, 
                             best_match_only = TRUE, 
                             preferred_data_sources = c(11))

head(resolved_GBIF)
summary(resolved_GBIF)
write.csv(resolved_GBIF, "speciesRresolvedGBIF.csv")



# IOC - 185 - update 2021-12

resolved_IOC <- gnr_resolve(raw_species$verbatimIdentification, 
                            data_source_ids = 185, 
                            canonical = TRUE)

head(resolved_IOC)
summary(resolved_IOC)
write.csv(resolved_IOC, "speciesRresolvedIOC.csv")


# BirdLife International - 175 - update 2014-12

resolved_BirdLife <- gnr_resolve(raw_species$verbatimIdentification, 
                                 data_source_ids = 175, 
                                 canonical = TRUE)

head(resolved_BirdLife)
summary(resolved_BirdLife)
write.csv(resolved_BirdLife, "speciesRresolved_BirdLife.csv")



# The eBird/Clements Checklist of Birds of the World - 187 - update 2021-12

resolved_eBC <- gnr_resolve(raw_species$verbatimIdentification, 
                            data_source_ids = 187, 
                            canonical = TRUE)

head(resolved_eBC)
summary(resolved_eBC)
write.csv(resolved_eBC, "speciesRresolved_eBC.csv")



# The Howard and Moore Complete Checklist of the Birds of the World - 189 - update 2020-05

resolved_HM <- gnr_resolve(raw_species$verbatimIdentification, 
                           data_source_ids = 189, 
                           canonical = TRUE)

head(resolved_HM)
summary(resolved_HM)
write.csv(resolved_HM, "speciesRresolved_HM.csv")
