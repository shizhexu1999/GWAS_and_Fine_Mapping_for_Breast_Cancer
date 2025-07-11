"""
GWAS Data Preparation and Cleaning Pipeline

Description:
This R script processes and cleans genotype, baseline, and endpoint data
from the China Kadoorie Biobank (CKB) for genome-wide association studies (GWAS).
It prepares covariate and phenotype files required for REGENIE analysis by:
1. Cleaning genetic data to extract PCs and basic IDs.
2. Extracting relevant endpoints and baseline questionnaire information.
3. Merging datasets and formatting files according to REGENIE requirements.
4. Filtering to include only female participants and excluding non-population subsets.

Required R packages: dplyr, data.table
Author: Shizhe Xu
Date: 09 July 2025
"""


library(dplyr)

###############################################################################
# Clean the gwas genetics data to get PCs and to combine with
# baseline and endpoints data later
###############################################################################

# load the ckb genetics data
# the total number of par8cipants with genotype data is 100706
file_path <- "/well/ckb/users/kws917/gwas_breast_cancer_confluence/data_gwas_genetics.rds"
data <- readRDS(file_path)

# remove irrelevant columns
columns_to_remove <- c(
  "csid", "gwas_batch", "ccvid_version",
  "principal_components_source", "is_immigrant", "gwas_array_type"
)
final_data <- data %>%
  select(-all_of(columns_to_remove))
# check the cleaned data
print(head(final_data))
print(names(final_data))

# try to fix the naming issues
# rename 'ccvid' to 'FID' and create 'IID' as a duplicate of 'FID'
final_data <- final_data %>%
  rename(FID = ccvid) %>%
  mutate(IID = FID)
# reorder columns to have 'FID' and 'IID' first
final_data <- final_data %>%
  select(FID, IID, everything())

# save the cleaned data
output_file <- "covariate_file_regenie_1.txt"
write.table(
  final_data,
  file = output_file,
  sep = " ",
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)


###############################################################################
# Clean the raw baseline and endpoints data, and extract required key information
###############################################################################

# Extract entries of endpoints containing diy_p1781594777(Carcinoma in situ of breast(*))
# and diy_p1232015483 (CKB0022 - Breast cancer (ICD-10: C50)(*)) and merge them
# for the phenotype file. Note that the date information is also included for
# time-to-event analysis in later anlaysis

# We also add diy_p1176798249 (CKB0014 - Malignant neoplasms) so that we can exclude incident
# cases of other cancer in later analysis

endpoints <- readRDS("/well/ckb/users/kws917/gwas_breast_cancer_confluence/endpoints.rds")

# define the patterns to match
patterns <- c("diy_p1232015483", "diy_p1781594777", "diy_p1176798249")

# extract the matching columns
columns_to_extract <- c("csid", grep(paste(patterns, collapse = "|"), colnames(endpoints), value = TRUE))
extracted_data <- endpoints[, columns_to_extract, drop = FALSE]

# print(head(extracted_data))
# save the extracted data to a csv file
output_file <- "extracted_endpoints.csv"
write.csv(extracted_data, file = output_file, row.names = FALSE)

# extract key information from baseline questionnaires
baseline_questionnaires <- readRDS("/well/ckb/users/kws917/gwas_breast_cancer_confluence/data_baseline_questionnaires.rds")
columns_to_extract <- c(
  "csid", "region_code", "region_is_urban", "study_date",
  "study_date_year", "study_date_month", "study_date_day",
  "study_date_hour", "study_date_time", "is_female",
  "dob_anon", "dob_y", "dob_m", "dob_d_anon",
  "age_at_study_date_x100", "cancer_diag", "cancer_site"
)

missing_columns <- setdiff(columns_to_extract, colnames(baseline_questionnaires))
if (length(missing_columns) > 0) {
  stop("The following columns are missing in the dataset: ", paste(missing_columns, collapse = ", "))
}

extracted_data <- baseline_questionnaires[, columns_to_extract, drop = FALSE]
# print(head(extracted_data))

# save the extracted data to a csv file
output_file <- "extracted_baseline_questionnaires.csv"
write.csv(extracted_data, file = output_file, row.names = FALSE)

# do some simple checkes

# extracted_baseline_questionnaires <- read.csv("extracted_baseline_questionnaires.csv")
# extracted_endpoints <- read.csv("extracted_endpoints.csv")
# # check if the `csid` columns exist in both datasets
# if (!"csid" %in% colnames(extracted_baseline_questionnaires) || !"csid" %in% colnames(extracted_endpoints)) {
#   stop("The `csid` column is missing in one or both datasets.")
# }
# # check if the number of rows is the same
# if (nrow(extracted_baseline_questionnaires) != nrow(extracted_endpoints)) {
#   cat("The datasets have different numbers of rows. Cannot compare row by row.\n")
# } else {
#   # compare `csid` values row by row
#   csid_match <- extracted_baseline_questionnaires$csid == extracted_endpoints$csid
#   if (all(csid_match, na.rm = TRUE)) {
#     cat("All rows in the `csid` columns are matched.\n")
#   } else {
#     cat("There are mismatches in the `csid` columns.\n")
#     # Identify and print mismatched rows
#     mismatched_rows <- which(!csid_match)
#     cat("Mismatched rows:\n")
#     print(mismatched_rows)

#     mismatched_values <- data.frame(
#       baseline_csid = extracted_baseline_questionnaires$csid[mismatched_rows],
#       endpoints_csid = extracted_endpoints$csid[mismatched_rows]
#     )
#     print(mismatched_values)
#   }
# }

###############################################################################
# Rename csid column to ensure the baseline and endpoints filec can be combined
# with genetics data later
###############################################################################

# replace the csid column in extracted_baseline_questionnaires.csv with its
# corresponding ccvid column from gwas_genetics
extracted_baseline_questionnaires <- read.csv("extracted_baseline_questionnaires.csv")
gwas_genetics <- readRDS("/well/ckb/users/kws917/gwas_breast_cancer_confluence/data_gwas_genetics.rds")
# merge `ccvid` from gwas_genetics into extracted_baseline_questionnaires using `csid`
merged_data <- merge(
  extracted_baseline_questionnaires,
  gwas_genetics[, c("csid", "ccvid")],  # Keep only csid and ccvid for merging
  by = "csid",  # Merge on the csid column
  all.x = TRUE  # Retain all rows from extracted_baseline_questionnaires
)

# replace `csid` with `ccvid`
merged_data$csid <- merged_data$ccvid
colnames(merged_data)[colnames(merged_data) == "csid"] <- "FID"

merged_data$IID <- merged_data$FID
column_order <- c("FID", "IID", setdiff(colnames(merged_data), c("FID", "IID")))
merged_data <- merged_data[, column_order]

# remove the old `ccvid` column
merged_data$ccvid <- NULL

output_file <- "updated_baseline_questionnaires.csv"
write.csv(merged_data, file = output_file, row.names = FALSE)


extracted_endpoints <- read.csv("extracted_endpoints.csv")
# gwas_genetics <- readRDS("data_gwas_genetics.rds")
if (!("csid" %in% colnames(gwas_genetics)) || !("ccvid" %in% colnames(gwas_genetics))) {
  stop("The columns `csid` and/or `ccvid` are missing in gwas_genetics.")
} else {
  cat("Success: Both `csid` and `ccvid` columns are present in gwas_genetics.\n")
}

merged_data <- merge(
  extracted_endpoints,
  gwas_genetics[, c("csid", "ccvid")],
  by = "csid",
  all.x = TRUE
)

merged_data$csid <- merged_data$ccvid
colnames(merged_data)[colnames(merged_data) == "csid"] <- "FID"

merged_data$IID <- merged_data$FID

column_order <- c("FID", "IID", setdiff(colnames(merged_data), c("FID", "IID")))
merged_data <- merged_data[, column_order]

merged_data$ccvid <- NULL

output_file <- "updated_extracted_endpoints.csv"
write.csv(merged_data, file = output_file, row.names = FALSE)

###############################################################################
# Combine updated_baseline_questionnaires.csv and updated_extracted_endpoints.csv
###############################################################################
baseline_questionnaires <- read.csv("updated_baseline_questionnaires.csv")
extracted_endpoints <- read.csv("updated_extracted_endpoints.csv")
combined_data <- merge(
  baseline_questionnaires,
  extracted_endpoints,
  by = c("FID", "IID"),
  all = TRUE
)
combined_data <- combined_data[order(match(combined_data$FID, baseline_questionnaires$FID)), ]
output_file <- "combined_baseline_and_endpoints.csv"
write.csv(combined_data, file = output_file, row.names = FALSE)

# convert csv file into txt file
# combined_data <- read.csv("combined_baseline_and_endpoints.csv")
# output_file <- "combined_baseline_and_endpoints.txt"
# write.table(
#   combined_data,
#   file = output_file,
#   row.names = FALSE,  # Exclude row names
#   col.names = TRUE,   # Include column names
#   sep = " ",          # Use a single space as the delimiter
#   quote = FALSE       # Exclude quotes around character data
# )
# cat("Combined data saved as space-delimited text file:", output_file, "\n")

###############################################################################
# Add age, region code, and PCs for ancestry to the covariate file
###############################################################################

# read baseline endpoints and covariate file
baseline_endpoints_file <- "combined_baseline_and_endpoints.csv"
covariate_file <- "covariate_file_regenie_1.txt"
output_file <- "covariate_file_regenie_with_subset.txt"

baseline_endpoints <- read.csv(baseline_endpoints_file)
covariates <- read.table(covariate_file, header = TRUE, stringsAsFactors = FALSE)

# merge covariate data with baseline endpoints (adding 'region_code' and 'age')
merged_data <- covariates %>%
  left_join(baseline_endpoints %>% select(FID, IID, region_code, age_at_study_date_x100),
            by = c("FID", "IID"))

write.table(
  merged_data,
  file = output_file,
  sep = "\t",         # Tab-delimited
  row.names = FALSE,  # Exclude row names
  quote = FALSE       # Avoid quotes around values
)

cat("Updated covariate file saved to", output_file, "\n")

###############################################################################
# Exclude the non-population subset for the above covariate file
# generate the final covaraite file used for REGENIE
###############################################################################
library(data.table)
file_path = "covariate_file_regenie_with_subset.txt"
output_path = "filtered_covariate_file_regenie_with_subset.txt"
df <- fread(file_path, sep = "\t")
df_filtered <- df[is_in_gwas_population_subset != 0]
fwrite(df_filtered, file = output_path, sep = "\t", quote = FALSE)

###############################################################################
# Prepare the phenotype file to include only females and key endpoints and
# baseline columns
###############################################################################
library(dplyr)
data <- read.csv("combined_baseline_and_endpoints.csv")
filtered_data <- data[data$is_female != 0, ]
output_file <- "women_only_combined_baseline_and_endpoints.csv"
write.csv(filtered_data, file = output_file, row.names = FALSE)

filtered_data <- read.csv("women_only_combined_baseline_and_endpoints.csv")

# columns_to_remove <- c(
#   "region_code", "study_date", "study_date_year", "study_date_month", "study_date_day",
#   "study_date_hour", "study_date_time", "is_female", "dob_anon", "dob_y", "dob_m",
#   "dob_d_anon", "ep_diy_p1232015483_combined_datedeveloped", "ep_diy_p1232015483_da_datedeveloped",
#   "ep_diy_p1232015483_dis_datedeveloped", "ep_diy_p1232015483_du_datedeveloped",
#   "ep_diy_p1232015483_hiip_datedeveloped", "ep_diy_p1232015483_hiop_datedeveloped",
#   "ep_diy_p1232015483_icase_datedeveloped", "ep_diy_p1232015483_oa_datedeveloped",
#   "ep_diy_p1232015483_pvd_datedeveloped", "ep_diy_p1781594777_combined_datedeveloped",
#   "ep_diy_p1781594777_da_datedeveloped", "ep_diy_p1781594777_dis_datedeveloped",
#   "ep_diy_p1781594777_du_datedeveloped", "ep_diy_p1781594777_hiip_datedeveloped",
#   "ep_diy_p1781594777_hiop_datedeveloped", "ep_diy_p1781594777_icase_datedeveloped",
#   "ep_diy_p1781594777_oa_datedeveloped", "ep_diy_p1781594777_pvd_datedeveloped"
# )

columns_to_remove <- c(
  "region_code", "study_date", "study_date_year", "study_date_month",
  "study_date_day", "study_date_hour", "study_date_time",
  "is_female", "dob_anon", "dob_y", "dob_m", "dob_d_anon"
)

# DIY panel IDs that have dated‐developed fields
diy_ids <- c("p1232015483", "p1781594777", "p1176798249")

# suffixes we want to drop (everything except "combined")
suffixes_to_drop <- c("da", "dis", "du", "hiip", "hiop", "icase", "oa", "pvd")

# build the full vector to remove
columns_to_remove <- c(
  columns_to_remove,
  unlist(
    lapply(diy_ids, function(id) {
      paste0("ep_diy_", id, "_", suffixes_to_drop, "_datedeveloped")
    })
  )
)

filtered_data <- filtered_data[, !(colnames(filtered_data) %in% columns_to_remove)]

output_file <- "filtered_women_only_combined_baseline_and_endpoints.csv"
write.csv(filtered_data, file = output_file, row.names = FALSE)

# convert csv into txt file for later process
data <- read.csv("filtered_women_only_combined_baseline_and_endpoints.csv")
output_file <- "filtered_women_only_combined_baseline_and_endpoints.txt"
write.table(
  data,
  file = output_file,
  row.names = FALSE,  # Do not include row names
  col.names = TRUE,   # Include column names
  sep = " ",          # Use space as the delimiter
  quote = FALSE       # Do not include quotes around values
)
cat("CSV file converted to space-delimited text file and saved to:", output_file, "\n")

# count the NA rows
filtered_data <- read.csv("filtered_women_only_combined_baseline_and_endpoints.csv")
non_na_count <- sum(!is.na(filtered_data$cancer_site))
cat("Number of non-NA rows in cancer_site:", non_na_count, "\n")
