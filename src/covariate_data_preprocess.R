###############################################################################
# we prepare the covariate file as Christiana suggested, removing participants
# who is not in population subset and is in related subset.
# By removing the above participants, it might reduce the number of cases significantly,
# which effects the statistical power of our analysis.
###############################################################################

install.packages("dplyr")
library(dplyr)
file_path <- "data_gwas_genetics.rds"
data <- readRDS(file_path)

# filter rows where is_in_gwas_population_subset = 1 and is_in_gwas_unrelated_subset = 1
filtered_data <- data %>%
  filter(is_in_gwas_population_subset == 1, is_in_gwas_unrelated_subset == 1)

print(head(filtered_data))
print(names(filtered_data))

# list of columns to remove
columns_to_remove <- c(
  "csid", "gwas_batch", "ccvid_version",
  "is_in_gwas_population_subset", "is_in_gwas_unrelated_subset",
  "principal_components_source", "is_immigrant", "gwas_array_type"
)
final_data <- filtered_data %>%
  select(-all_of(columns_to_remove))

print(head(final_data))
print(names(final_data))

final_data <- final_data %>%
  rename(FID = ccvid) %>%
  mutate(IID = FID)

final_data <- final_data %>%
  select(FID, IID, everything())

output_file <- "covariate_file_regenie_1.txt"

write.table(
  final_data,
  file = output_file,
  sep = " ",        # Space-delimited
  row.names = FALSE, # Exclude row names
  col.names = TRUE,  # Include column names
  quote = FALSE      # Avoid quotes around values
)

###############################################################################
# With Christiana and Ahmed's suggestions, we want to add age, region code and
# PCs for ancestry to the covariate file
###############################################################################

baseline_endpoints_file <- "combined_baseline_and_endpoints.csv"
covariate_file <- "covariate_file_regenie.txt"
output_file <- "updated_covariate_file_regenie.txt"


baseline_endpoints <- read.csv(baseline_endpoints_file)
covariates <- read.table(covariate_file, header = TRUE, stringsAsFactors = FALSE)


merged_data <- covariates %>%
  left_join(baseline_endpoints %>% select(FID, IID, region_code, age_at_study_date_x100),
            by = c("FID", "IID"))


write.table(merged_data, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)

cat("Updated covariate file saved to", output_file, "\n")
