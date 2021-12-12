require(readxl)
require(tidyverse)
require(dplyr)
require(stringr)


#Questions:
#Added "H" in front of all patients in the old DB, is that okay?
#only 20 or so patients that intersect?
#Use component type description, PPH -> platlet

#Loading datasets
BB_data = read_xlsx("F:/November/1Jan-31Mar2021 Blood Bank data.xlsx")
Patient_data1 = read_xlsx("F:/November/All patients 2011Apr6-2020Dec31 clean labels.xlsx")
Patient_data2 = read_xlsx("F:/November/2021Jan1-Mar31 TR data for BB link and allpts merge.xlsx")

#Consolidating Columns
Patient_data2 = Patient_data2 %>% dplyr::rename("MRN" = "MRN (H=HMC#, no letter=Epic" ,
                                                "Dig age" = "Dig Age yrs" ,"Mechanism bin" = "Mechanism Bin (o_u=explosion, hanging," )

Patient_data1$MRN = Patient_data1$MRN %>% as.character() %>% str_pad(7, side = "left", pad = "0")
Patient_data1$MRN = paste("H",Patient_data1$MRN, sep = "")

Patient_data2$MRN = Patient_data2$MRN %>% as.character() %>% str_pad(7, side = "left", pad = "0")
Patient_data2$MRN = Patient_data2$MRN %>% as.character() %>% str_pad(8, side = "left", pad = "U")

Patient_data1$`TtD hrs` = as.numeric(Patient_data1$`TtD hrs`)

#Merging patient datasets
Patient_data = Patient_data1 %>% full_join(Patient_data2, by = intersect(names(Patient_data1), names(Patient_data2)))

#Merging BB and patient datasets
MRNS = intersect(Patient_data$MRN, BB_data$`Patient Id`)
BB_data = BB_data %>% subset(`Patient Id` %in% MRNS)
BB_data$Unit_type = BB_data$Product %>% replace(BB_data$Product == "PLSG", "Plasma") %>% 
  replace(BB_data$Product == "RBCG", "RBC") %>%
  replace(BB_data$Product == "PLG", "Plt") %>%
  replace(BB_data$Product == "CRYG", "Cryo") 
table(BB_data$`Patient Id`, BB_data$Unit_type)
