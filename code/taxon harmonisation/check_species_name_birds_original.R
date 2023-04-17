#####################################
# Code to Check species names. (DwC term: scientificName).
# Author: Florencia Grattarola
# Date: 2022-12-07

# Description: The script contains a function that takes a species list as input and returns a dataframe with two columns: Species Name and Observation. The run will return the result of the check for each species in the list, doing it first with ITIS database (Integrated Taxonomic Information System) and then with IUCN database (IUCN Red List of Threatened Species) case the species is not found in ITIS. If the species has a match in any of the databases, it will return the same Species Name and 'Ok ITIS' or 'Ok IUCN' as Observation. If the species has a match with any error of spelling, it will return the matched correct name in Species Name and 'Checked ITIS' or 'Checked IUCN' as Observation. If the species is not found in any of the databases, it will return 'NOT FOUND in ITIS or IUCN' as Observation.

#####################################

# LIBRARIES

library(taxize)
library(tidyverse)

#####################################

# TAXONOMIC DATA SOURCES

sources <- gnr_datasources()

name_source_1 <-'IOC World Bird List'
id_source_1 <- sources$id[sources$title == name_source_1]

name_source_2 <-'BirdLife International'
id_source_2 <- sources$id[sources$title == name_source_2]

sources <- data.frame(source= c(1,2), 
                     name=c(name_source_1, name_source_2), 
                     id=c(id_source_1, id_source_2))

#####################################

# FUNCTION

check_name <- function(species, sources){
  species_checked <- data.frame(previousIdentification = character(),
                                scientificName = character(),
                                observation = character(), 
                                stringsAsFactors=FALSE)
  for(sp in species) {
    cat(sp, '\n')
    sp_check_1 <- gnr_resolve(sp, data_source_ids=sources$id[1], with_canonical_ranks = TRUE)
    if (nrow(sp_check_1)==0){
      sp_check_2 <- gnr_resolve(sp, data_source_ids=sources$id[2], with_canonical_ranks = TRUE)
      if (nrow(sp_check_2)==0){
        sp_checked <- data.frame(previousIdentification = sp,
                                 scientificName = NA,
                                 observation = str_glue('NOT FOUND in {sources$name[1]} or {sources$name[2]}'), 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
      else if (nrow(sp_check_2)!=0 && sp!=sp_check_2$matched_name2[1]){
        sp_checked <- data.frame(previousIdentification = sp,
                                 scientificName = sp_check_2$matched_name2[1],
                                 observation = str_glue('Updated according to {sources$name[2]}'), 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
      else{
        sp_checked <- data.frame(previousIdentification = sp,
                                 scientificName = sp,
                                 observation = str_glue('Ok ({sources$name[2]})'), 
                                 stringsAsFactors=FALSE)
        species_checked <- rbind(species_checked, sp_checked)
      }
    } 
    else if (nrow(sp_check_1)!=0 && sp!=sp_check_1$matched_name2[1]){
      sp_checked <- data.frame(previousIdentification = sp,
                               scientificName = sp_check_1$matched_name2[1],
                               observation = str_glue('Updated according to {sources$name[1]}'), 
                               stringsAsFactors=FALSE)
      species_checked <- rbind(species_checked, sp_checked)
    } 
    else {
      sp_checked <- data.frame(previousIdentification = sp,
                               scientificName = sp,
                               observation = str_glue('Ok ({sources$name[1]})'), 
                               stringsAsFactors=FALSE)
      species_checked <- rbind(species_checked, sp_checked)
    }
  }
  return(species_checked)
}

#####################################
# TEST RUN

# Species List

birds <- c('Falco sparverius', 'Falco sparveriu', 'Ealco sparverius')
birds_species_check <- check_name(birds, sources)
birds_species_check

#   previousIdentification   scientificName                              observation
# 1       Falco sparverius Falco sparverius                 Ok (IOC World Bird List)
# 2        Falco sparveriu Falco sparverius Updated according to IOC World Bird List
# 3       Ealco sparverius Falco sparverius Updated according to IOC World Bird List

#####################################
# RUN

# Data from table

CZ_birds <- read_csv('../../../Downloads/speciesAccess.csv')
CZ_birds <- CZ_birds %>% mutate(verbatimIdentification=str_squish(verbatimIdentification))
head(CZ_birds)

CZ_birds_species_check <- check_name(CZ_birds$verbatimIdentification, sources)
head(CZ_birds_species_check)

#        previousIdentification             scientificName                              observation
# 1          Accipiter gentilis         Accipiter gentilis                 Ok (IOC World Bird List)
# 2             Accipiter nisus            Accipiter nisus                 Ok (IOC World Bird List)
# 3    Acrocephallus scripaceus    Acrocephalus scirpaceus Updated according to IOC World Bird List
# 4   Acrocephalus arundinaceus  Acrocephalus arundinaceus                 Ok (IOC World Bird List)
# 5    Acrocephalus melanopogon   Acrocephalus melanopogon                 Ok (IOC World Bird List)
# 6     Acrocephalus paludicola    Acrocephalus paludicola                 Ok (IOC World Bird List)
# 7      Acrocephalus palustris     Acrocephalus palustris                 Ok (IOC World Bird List)
# 8     Acrocephalus scirpaceus    Acrocephalus scirpaceus                 Ok (IOC World Bird List)
# 9  Acrocephalus schoenobaenus Acrocephalus schoenobaenus                 Ok (IOC World Bird List)
# 10          Actitis hypoleuca         Actitis hypoleucos Updated according to IOC World Bird List
# 11         Actitis hypoleucos         Actitis hypoleucos                 Ok (IOC World Bird List)
# 12        Aegithalos caudatus        Aegithalos caudatus                 Ok (IOC World Bird List)
# 13        Aegithatos caudatus        Aegithalos caudatus Updated according to IOC World Bird List
# 14          Aegolius funereus          Aegolius funereus                 Ok (IOC World Bird List)
# 15           Aix galericulata           Aix galericulata                 Ok (IOC World Bird List)
# 16            Alauda arvensis            Alauda arvensis                 Ok (IOC World Bird List)
# 17              Alcedo atthis              Alcedo atthis                 Ok (IOC World Bird List)
# 18       Alopochen aegyptiaca       Alopochen aegyptiaca                 Ok (IOC World Bird List)
# 19                 Anas acuta                 Anas acuta                 Ok (IOC World Bird List)
# 20              Anas clypeata              Anas clypeata              Ok (BirdLife International)
# 21                Anas crecca                Anas crecca                 Ok (IOC World Bird List)
# 22              Anas penelope              Anas penelope              Ok (BirdLife International)
# 23         Anas platyrhynchos         Anas platyrhynchos                 Ok (IOC World Bird List)
# 24        Anas platyrchynchos         Anas platyrhynchos Updated according to IOC World Bird List
# 25           Anas querquedula           Anas querquedula              Ok (BirdLife International)


