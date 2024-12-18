library(data.table)

baseline_questionnaires <- readRDS("data_baseline_questionnaires.rds")
first_row_baseline <- names(baseline_questionnaires)
print(first_row_baseline)
View(baseline_questionnaires)

gwas_ascertainments <- readRDS("data_gwas_ascertainments.rds")
View(gwas_ascertainments)
head(gwas_ascertainments)
first_row_name <- names(gwas_ascertainments)
print(first_row_name)

gwas_genetics <- readRDS("data_gwas_genetics.rds")
View(gwas_genetics)
print(gwas_genetics.head)
print(colnames(gwas_genetics))
row_name <- names(gwas_genetics)
print(row_name)
print(head(gwas_genetics))

# check if the column contains any 0 values
# this column contains PCs from GWAS or Clinic Averages
contains_zero <- any(gwas_genetics$principal_components_source == 0)
if (contains_zero) {
  print("The column 'principal_components_source' contains 0 values.")
} else {
  print("The column 'principal_components_source' does
  not contain any 0 values.")
}

endpoints <- readRDS("endpoints.rds")
View(endpoints)
print(colnames(endpoints))

# extract the specific csid to inspect
cols_to_keep <- grepl("ep_diy_p1781594777", colnames(endpoints)) |
  grepl("ep_diy_p1232015483", colnames(endpoints))
print(colnames(endpoints)[cols_to_keep])
selected_columns <- c("csid", colnames(endpoints)[cols_to_keep])
# subset the data.table using .. to indicate the variable in calling space
filtered_endpoints <- endpoints[, ..selected_columns]
View(filtered_endpoints)

endpoints_definition <- readRDS("endpoint_definitions.rds")
View(endpoints_definition)

#############################################################################
# check if the `csid` columns are matched row by row
# ensure `csid` column exists in both datasets
# if `csid` entries are matched in both datasets, we can combine them directly
#############################################################################

if (!"csid" %in% colnames(endpoints) || !"csid" %in% colnames(gwas_genetics)) {
  stop("The `csid` column is missing in one or both datasets.")
}

# ensure both datasets have the same number of rows
if (nrow(endpoints) != nrow(gwas_genetics)) {
  stop("The two datasets have different numbers of rows. Cannot compare row by row.")
}

# compare `csid` columns row by row
csid_match <- endpoints$csid == gwas_genetics$csid

# output the result
if (all(csid_match, na.rm = TRUE)) {
  cat("All rows in the `csid` columns are matched.\n")
} else {
  cat("There are mismatches in the `csid` columns.\n")

  # identify and print mismatched rows
  mismatched_rows <- which(!csid_match)
  cat("Mismatched rows:\n")
  print(mismatched_rows)

  mismatched_values <- data.frame(
    endpoints_csid = endpoints$csid[mismatched_rows],
    gwas_genetics_csid = gwas_genetics$csid[mismatched_rows]
  )
  print(mismatched_values)
}
