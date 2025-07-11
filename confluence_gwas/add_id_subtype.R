"""
Add the corresponding ID to the breast cancer subtype data

Required R packages: dplyr, data.table
Author: Shizhe Xu
Date: 09 July 2025
"""
###############################################################################
# Add the IID and FID to match with our phenotype and genotype data
###############################################################################

library(dplyr)

rds_file <- "/well/ckb/users/kws917/gwas_breast_cancer_confluence/data_March_9/data_gwas_genetics.rds"
csv_file <- "DAR-2025-00079.breast_filtered_header_classification.csv"
output_file <- "DAR-2025-00079.breast_filtered_header_classification_ccvid.csv"

rds_data <- readRDS(rds_file)
csv_data <- read.csv(csv_file, stringsAsFactors = FALSE)
if (!all(c("csid", "ccvid") %in% colnames(rds_data))) {
  stop("The RDS file does not contain the required 'csid' or 'ccvid' columns.")
}
if (!"csid" %in% colnames(csv_data)) {
  stop("The CSV file does not contain the 'csid' column.")
}


rds_selected <- rds_data %>% select(csid, ccvid)
merged_data <- left_join(csv_data, rds_selected, by = "csid")
write.csv(merged_data, output_file, row.names = FALSE)

cat("Merged data saved to:", output_file, "\n")
