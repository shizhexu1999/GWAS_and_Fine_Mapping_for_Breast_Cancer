###############################################################################
# Extract entries of endpoints containing diy_p1781594777(Carcinoma in situ of breast(*))
# and diy_p1232015483 (CKB0022 - Breast cancer (ICD-10: C50)(*)) and merge them
# for the phenotype file. Note that the date information is also included for
# time-to-event analysis in the near future.
##############################################################################

endpoints <- readRDS("endpoints.rds")

# define the patterns to match
patterns <- c("diy_p1232015483", "diy_p1781594777")

# extract the matching columns
columns_to_extract <- c("csid", grep(paste(patterns, collapse = "|"), colnames(endpoints), value = TRUE))
extracted_data <- endpoints[, columns_to_extract, drop = FALSE]

print(head(extracted_data))
output_file <- "extracted_endpoints.csv"
write.csv(extracted_data, file = output_file, row.names = FALSE)

cat("Extracted data saved to:", output_file, "\n")

###############################################################################
# Extract entries of baseline questionnaires suggested by Christiana
##############################################################################
baseline_questionnaires <- readRDS("data_baseline_questionnaires.rds")
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
print(head(extracted_data))

# save the extracted data to a CSV file
output_file <- "extracted_baseline_questionnaires.csv"
write.csv(extracted_data, file = output_file, row.names = FALSE)

cat("Extracted data saved to:", output_file, "\n")

#############################################################################
# we still need to check if the `csid` rows are matched
#############################################################################

extracted_baseline_questionnaires <- read.csv("extracted_baseline_questionnaires.csv")
extracted_endpoints <- read.csv("extracted_endpoints.csv")

# check if the `csid` columns exist in both datasets
if (!"csid" %in% colnames(extracted_baseline_questionnaires) || !"csid" %in% colnames(extracted_endpoints)) {
  stop("The `csid` column is missing in one or both datasets.")
}

# check if the number of rows is the same
if (nrow(extracted_baseline_questionnaires) != nrow(extracted_endpoints)) {
  cat("The datasets have different numbers of rows. Cannot compare row by row.\n")
} else {
  # compare `csid` values row by row
  csid_match <- extracted_baseline_questionnaires$csid == extracted_endpoints$csid
  if (all(csid_match, na.rm = TRUE)) {
    cat("All rows in the `csid` columns are matched.\n")
  } else {
    cat("There are mismatches in the `csid` columns.\n")
    # identify and print mismatched rows
    mismatched_rows <- which(!csid_match)
    cat("Mismatched rows:\n")
    print(mismatched_rows)

    mismatched_values <- data.frame(
      baseline_csid = extracted_baseline_questionnaires$csid[mismatched_rows],
      endpoints_csid = extracted_endpoints$csid[mismatched_rows]
    )
    print(mismatched_values)
  }
}
