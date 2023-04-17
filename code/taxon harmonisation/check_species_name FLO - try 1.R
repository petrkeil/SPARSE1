
############################     TAXONOMY CHECK     ############################
# by Flo Grattarola

library(taxize)
library(tidyverse)


# --------------- SET WORKING DIRECTORY ----------------------------------------

getwd()
setwd('C:/Users/tschernosterova/OneDrive - CZU v Praze/SPARSE/code/taxon harmonisation')
getwd()


# --------------- READ INPUT DATA ----------------------------------------------

raw_species<-read.csv('speciesAccess.csv',header=T)
head(raw_species)

str(raw_species)
summary(raw_species)

# names(raw_species)[names(raw_species) == 'ï..verbatimIdentification'] <- 'verbatimIdentification'
# head(raw_species)
# in case the csv would be in UTF-8 format


# --------------- TAXONOMIC DATA SOURCES ---------------------------------------

sources <- gnr_datasources()

itis <- sources$id[sources$title == 'Integrated Taxonomic Information SystemITIS']
iucn <- sources$id[sources$title == 'IUCN Red List of Threatened Species']

birdL <- sources$id[sources$title == 'BirdLife International']
IOC <- sources$id[sources$title == 'IOC World Bird List']


# --------------- DEFINE FUNCTION ----------------------------------------------

check_name <- function(raw_species){
  species_checked <- data.frame(verbatimIdentification = character(),
                                scientificName = character(),
                                observation = character(), 
                                stringsAsFactors=FALSE)
  # definice výstupu funkce - co bude výsledný DF obsahovat
  
  
  for(verbatimIdentification in raw_species) {
      sp_check_birdL <- gnr_resolve(verbatimIdentification, data_source_ids=birdL, with_canonical_ranks = TRUE)
    
    if (nrow(sp_check_birdL)==0){
        sp_check_IOC <- gnr_resolve(verbatimIdentification, data_source_ids=IOC, with_canonical_ranks = TRUE)
    
    if (nrow(sp_check_IOC)==0){
        sp_checked <- data.frame(verbatimIdentification = verbatimIdentification,
                                 scientificName = NA,
                                 observation = 'NOT FOUND in BirdLife or IOC', 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
     else if (nrow(sp_check_IOC)!=0 && verbatimIdentification!=sp_check_IOC$matched_name2){
      sp_checked <- data.frame(verbatimIdentification = verbatimIdentification,
                                scientificName = sp_check_IOC$matched_name2,
                                 observation = 'Checked IOC', 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
     else{
       sp_checked <- data.frame(verbatimIdentification = verbatimIdentification,
                                scientificName = verbatimIdentification,
                                  observation = 'Ok IOC', 
                                stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
    } 
    else if (nrow(sp_check_birdL)!=0 && verbatimIdentification!=sp_check_birdL$matched_name2){
       sp_checked <- data.frame(previousIdentification = verbatimIdentification,
                                 scientificName = sp_check_birdL$matched_name2,
                                observation = 'Checked birdL', 
                                stringsAsFactors=FALSE)
       species_checked <- rbind(species_checked, sp_checked)
     } 
     else {
       sp_checked <- data.frame(previousIdentification = verbatimIdentification,
                                scientificName = verbatimIdentification,
                                observation = 'Ok birdL', 
                               stringsAsFactors=FALSE)
     species_checked <- rbind(species_checked, sp_checked)
    }
  }
  return(species_checked)
}


# --------------- RUN THE FUNCTION FOR SPARSE ----------------------------------

SPARSE_species_check <- check_name(raw_species)

head(SPARSE_species_check)
summary(SPARSE_species_check)
write.csv(SPARSE_species_check, "SPARSE_BirdL&IOC_species_check.csv")


# SPARSE_species_check <- check_name(raw_species$verbatimIdentification)

# Error in match.names(clabs, names(xi)) : names do not match previous names     !!!!!!!!!!!! ERROR !!!!!!!!!!!
# 5. stop("names do not match previous names")
# 4. match.names(clabs, names(xi))
# 3. rbind(deparse.level, ...)
# 2. rbind(species_checked, sp_checked)
# 1. check_name(raw_species$verbatimIdentification)


# function (clabs, nmi)                                                          !!!!!!!!!!!!!! DEBUG !!!!!!!!!!!!!!!!!!
# {
#  if (identical(clabs, nmi)) 
#    NULL
#  else if (length(nmi) == length(clabs) && all(nmi %in% clabs)) {
#    m <- pmatch(nmi, clabs, 0L)
#   if (any(m == 0L)) 
#     stop("names do not match previous names")
#    m
#  }
#  else stop("names do not match previous names")
# }


#  FROM FLO --------------------------------------------------------------------


# 1) Species List
#canids <- c('Cerdocyon thous', 'Cerdocyon thou', 'Aerdocyon thou')
#canids_species_check <- check_name(canids)
#canids_species_check

#   previousIdentification  scientificName  observation
# 1        Cerdocyon thous Cerdocyon thous      Ok ITIS
# 2         Cerdocyon thou Cerdocyon thous Checked ITIS
# 3         Aerdocyon thou Cerdocyon thous Checked ITIS

# 2) Data from table
#mammals <- read_csv('tetrapodsSpeciesList.csv')
#mammlas_species_check <- check_name(mammals$Species)
#mammlas_species_check



#       previousIdentification            scientificName               observation
# 1         Mazama gouazoubira        Mazama gouazoubira                   Ok ITIS
# 2                  Axis axis                 Axis axis                   Ok ITIS
# 3                 Sus scrofa                Sus scrofa                   Ok ITIS
# 4            Cerdocyon thous           Cerdocyon thous                   Ok ITIS
# 5      Chrysocyon brachyurus     Chrysocyon brachyurus                   Ok ITIS
# 6      Lycalopex gymnocercus     Lycalopex gymnocercus                   Ok ITIS
# 7           Leopardus wiedii          Leopardus wiedii                   Ok ITIS
# 8        Leopardus braccatus       Leopardus braccatus                   Ok ITIS
# 9        Leopardus geoffroyi       Leopardus geoffroyi                   Ok ITIS
# 10         Puma yagouaroundi         Puma yagouaroundi                   Ok ITIS
# 11        Lontra longicaudis        Lontra longicaudis                   Ok ITIS
# 12          Conepatus chinga          Conepatus chinga                   Ok ITIS
# 13             Galictis cuja             Galictis cuja                   Ok ITIS
# 14       Procyon cancrivorus       Procyon cancrivorus                   Ok ITIS
# 15      Dasypus novemcinctus      Dasypus novemcinctus                   Ok ITIS
# 16     Euphractus sexcinctus     Euphractus sexcinctus                   Ok ITIS
# 17         Cabassous tatouay         Cabassous tatouay                   Ok ITIS
# 18     Didelphis albiventris     Didelphis albiventris                   Ok ITIS
# 19           Lepus europaeus           Lepus europaeus                   Ok ITIS
# 20            Cuniculus paca            Cuniculus paca                   Ok ITIS
# 21                No species                      <NA> NOT FOUND in ITIS or IUCN
# 22 Hydrochoerus hydrochaeris Hydrochoerus hydrochaeris                   Ok ITIS
# 23     Tamandua tetradactyla     Tamandua tetradactyla                   Ok ITIS