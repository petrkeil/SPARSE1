#####################################
#        Check Species Names        #
#####################################

library(taxize)
library(tidyverse)

#####################################

getwd()
setwd('C:/Users/tschernosterova/OneDrive - CZU v Praze/SPARSE/code/taxon harmonisation')
getwd()



# TAXONOMIC DATA SOURCES
sources <- gnr_datasources()
IOC <- sources$id[sources$title == 'IOC World Bird List']
BirdLife <- sources$id[sources$title == 'BirdLife International']

#####################################

# FUNCTION

check_name <- function(species){
  species_checked <- data.frame(verbatimIdentification = character(),
                                scientificName = character(),
                                observation = character(), 
                                stringsAsFactors=FALSE)
  for(sp in species) {
    
    sp_check_IOC <- gnr_resolve(sp, data_source_ids=IOC, with_canonical_ranks = TRUE)
    if (nrow(sp_check_IOC)==0){
      
    sp_check_BirdLife <- gnr_resolve(sp, data_source_ids=BirdLife, with_canonical_ranks = TRUE)
    if (nrow(sp_check_BirdLife)==0){
        sp_checked <- data.frame(verbatimIdentification = sp,
                                 scientificName = NA,
                                 observation = 'NOT FOUND in IOC or BirdLife', 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
    }
    
    else if (nrow(sp_check_BirdLife)!=0 && sp!=sp_check_BirdLife$matched_name2){
        sp_checked <- data.frame(verbatimIdentification = sp,
                                 scientificName = sp_check_BirdLife$matched_name2,
                                 observation = 'Checked BirdLife', 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
    }
    
    else{
        sp_checked <- data.frame(verbatimIdentification = sp,
                                 scientificName = sp,
                                 observation = 'Ok BirdLife', 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
    } 
    
    else if (nrow(sp_check_IOC)!=0 && sp!=sp_check_IOC$matched_name2){
      sp_checked <- data.frame(verbatimIdentification = sp,
                               scientificName = sp_check_IOC$matched_name2,
                               observation = 'Checked IOC', 
                               stringsAsFactors=FALSE)
      species_checked <- rbind(species_checked, sp_checked)
    } 
    else {
      sp_checked <- data.frame(verbatimIdentification = sp,
                               scientificName = sp,
                               observation = 'Ok IOC', 
                               stringsAsFactors=FALSE)
      species_checked <- rbind(species_checked, sp_checked)
    }
  }
  return(species_checked)
}

#####################################
# RUN

# 1) Species List
# canids <- c('Cerdocyon thous', 'Cerdocyon thou', 'Aerdocyon thou')
# canids_species_check <- check_name(canids)
# canids_species_check

#   previousIdentification  scientificName  observation
# 1        Cerdocyon thous Cerdocyon thous      Ok ITIS
# 2         Cerdocyon thou Cerdocyon thous Checked ITIS
# 3         Aerdocyon thou Cerdocyon thous Checked ITIS

# 2) Data from table
CZ_birds <- read_csv("speciesAccess.csv")
head(CZ_birds)

CZ_birds_species_check <- check_name(CZ_birds)
CZ_birds_species_check %>% View
write.csv(CZ_birds_species_check, "speciesRresolved_IOC&BirdList_FloScript.csv")
                                                                                # Warning message:
                                                                                # In sp != sp_check_IOC$matched_name2 :
                                                                                #   longer object length is not a multiple of shorter object length


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