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
