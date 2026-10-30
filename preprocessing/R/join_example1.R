library(data.table)

######## Example 1: Join lab observations with encounter and patient data #########

#### Step 1: read data ####
# adapt the path to the example data if necessary
patient <- fread("example_data/Patient _ Patientin pseudonymisiert.csv", na.strings = "" )
encounter <- fread("example_data/Fall - Kontakt mit einer Gesundheitseinrichtung.csv", na.strings = "")
lab_obs <- fread("example_data/Laboruntersuchung.csv", na.strings = "")

#### Step 2: Reduce and rename columns ####

pat <- patient[,.(
  pat_id = id,
  deceased = Patient_deceased_X_Deceasedboolean
  )]

enc <- encounter[,.(
  enc_id = id,
  pat_id = sub("Patient/", "", patient), # remove Resource type from reference ids for later merging
  enc_start = Encounter_period_start,
  enc_end = Encounter_period_end,
  enc_type_code = Encounter_type_coding_code,
  enc_type_system = Encounter_type_coding_system
)]

lab <- lab_obs[,.(
  obs_id = id,
  pat_id = sub("Patient/", "", patient), # remove Resource type from reference ids for later merging
  datetime = Observation_effective_X_Effectivedatetime,
  code = Observation_code_coding_code,
  code_system = Observation_code_coding_system,
  value = Observation_value_X_Valuequantity_value,
  value_code = Observation_value_X_Valuequantity_code,
  value_system = Observation_value_X_Valuequantity_system
)]


#### Step 3: Reduce rows ####

# Multiple rows per resource can result from spreading repeating elements across rows.
# Identical rows can be removed without further decisions.
# Rows that differ in one or more columns require a decision about which to keep.

### Patient table
# Remove identical duplicate rows
pat <- unique(pat)

# Check whether each patient occurs exactly once
length(unique(pat$pat_id)) == nrow(pat) # TRUE

### Encounter table
# Remove identical duplicate rows
enc <- unique(enc)

# Check whether each encounter occurs exactly once
length(unique(enc$enc_id)) == nrow(enc) # FALSE

# Remaining duplicates differ in encounter.type.coding:
# http://fhir.de/CodeSystem/Kontaktebene or http://fhir.de/CodeSystem/kontaktart-de

# One encounter is an operation/versorgungsstellenkontakt
table(enc$enc_type_code, enc$enc_type_system)

# Keep only Einrichtungskontakte (Kontaktebene)
enc <- enc[enc_type_code == "einrichtungskontakt"]

### Merge the three resource types
### Left join encounter data to lab data
### Then left join patient data to it

#Merge observation and encounter data
data <- merge.data.table(x = lab,
                         y = enc,
                         by = c("pat_id"),
                         all.x = TRUE, all.y = FALSE)

#Merge patient data
data <- merge.data.table(x = data, 
                         y = pat,
                         by = "pat_id",
                         all.x = TRUE, all.y = FALSE)


