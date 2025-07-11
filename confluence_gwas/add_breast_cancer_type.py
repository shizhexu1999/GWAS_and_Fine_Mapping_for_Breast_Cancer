"""
CKB Phenotype Data Cleaning and Breast Cancer Subtype Classification

Description:
This script processes phenotype data from the China Kadoorie Biobank (CKB) to prepare
files required for genome-wide association studies (GWAS) focusing on breast cancer.
1. Splits cancer sites into specific regions for participants with cancer history.
2. Defines overall breast cancer status following Confluence project definitions.
3. Removes participants with other cancers before or overlapping with breast cancer.
4. Merges external breast cancer subtype information (ER-positive, ER-negative, triple-negative).
5. Creates separate phenotype files for each breast cancer subtype.

Required Python packages: pandas
Author: Shizhe Xu
Date: 09 July 2025
"""

import pandas as pd

###############################################################################
# Split the cancer sites into specific regions given cancer_diag == 1
# note that this is cancer prevalent, and partcipants have history of invasive cancer
###############################################################################

phenotype_file = "filtered_women_only_combined_baseline_and_endpoints.txt"
pheno_data = pd.read_csv(phenotype_file, delim_whitespace=True)

non_na_count = pheno_data["cancer_site"].notna().sum()
print(f"Number of non-NA entries in cancer_site: {non_na_count}")

count_five = (pheno_data["cancer_site"] == 5).sum()
print(f"Number of entries with value 5 in cancer_site: {count_five}")

# we define specific cancer site mapping
cancer_sites = {
    0: "Lung",
    1: "Esophagus",
    2: "Stomach",
    3: "Liver",
    4: "Intestine",
    5: "Breast",
    6: "Prostate",
    7: "Cervix",
    8: "Other",
}

for site_value, site_name in cancer_sites.items():
    pheno_data[f"cancer_{site_name}"] = pheno_data["cancer_site"].apply(
        lambda x: 1 if x == site_value else (0 if not pd.isna(x) else "NA")
    )

breast_cancer_count = (pheno_data["cancer_Breast"] == 1).sum()
print(f"Number of rows with entry 1 in cancer_Breast: {breast_cancer_count}")


output_file = "updated_filtered_women_only_combined_baseline_and_endpoints.txt"
pheno_data.to_csv(output_file, sep="\t", index=False)

print(f"Updated file with additional cancer site columns saved to {output_file}")

###############################################################################
# Define the overall breast cancer to meet the requirements of the Confluence project
# including all female participants diagnosed with breast cancer (in-situ or invasive)
# which means including ICD10 C50 diy_p1232015483 and D05 diy_p1781594777
###############################################################################

file_path = "updated_filtered_women_only_combined_baseline_and_endpoints.txt"
df = pd.read_csv(file_path, sep="\t")

df["breast_cancer_prevalent"] = (
    (df["cancer_diag"] == 1) & (df["cancer_Breast"] == 1)
).astype(int)

df["breast_cancer"] = (
    (df["breast_cancer_prevalent"] == 1)
    | (df["ep_diy_p1232015483_combined_ep"] == 1)
    | (df["ep_diy_p1781594777_combined_ep"] == 1)
).astype(int)

na_count = df["breast_cancer"].isna().sum()
ones_count = (df["breast_cancer"] == 1).sum()

print(f"Number of NAs in 'breast_cancer': {na_count}")
print(f"Number of 1s in 'breast_cancer': {ones_count}")

output_path = (
    "final_filtered_women_only_combined_baseline_and_endpoints_with_breast_cancer.txt"
)
df.to_csv(output_path, sep="\t", index=False)

print(f"File saved with new columns to: {output_path}")


###############################################################################
# Remove participants who have cancer_diag == 1 but the site is not breast cancer
# before enrolling into the study
###############################################################################

infile = (
    "final_filtered_women_only_combined_baseline_and_endpoints_with_breast_cancer.txt"
)
df = pd.read_csv(infile, sep="\t")

other_cancer_cols = [
    "cancer_Lung",
    "cancer_Esophagus",
    "cancer_Stomach",
    "cancer_Liver",
    "cancer_Intestine",
    "cancer_Prostate",
    "cancer_Cervix",
    "cancer_Other",
]

mask_has_other_cancer = (df["cancer_diag"] == 1) & df[other_cancer_cols].any(axis=1)

df_filtered = df.loc[~mask_has_other_cancer].copy()

outfile = "phenotype_file_without_other_cancer_before_study.txt"
df_filtered.to_csv(outfile, sep="\t", index=False)

print(f"Kept {df_filtered.shape[0]:,} of {df.shape[0]:,} rows. Saved to {outfile}.")

n_bc_filtered = (df_filtered["breast_cancer"] == 1).sum()
print(f"Entries with breast_cancer == 1 after filtering: {n_bc_filtered:,}")


###############################################################################
# Remove participants who develop incident other cancer before incident breast cancer
###############################################################################

infile = "phenotype_file_without_other_cancer_before_study.txt"

col_other_cancer_ep = "ep_diy_p1176798249_combined_ep"

date_other_cancer = "ep_diy_p1176798249_combined_datedeveloped"
date_carcinoma = "ep_diy_p1781594777_combined_datedeveloped"
date_breast_cancer = "ep_diy_p1232015483_combined_datedeveloped"

df = pd.read_csv(infile, sep="\t", dtype={col_other_cancer_ep: "Int64"})

# for col in (date_other_cancer, date_carcinoma, date_breast_cancer):
#     df[col] = pd.to_datetime(df[col], errors="coerce")

# # build the exclusion mask
# mask_drop = (
#     (df[col_other_cancer_ep] == 1)
#     &
#     (
#         # other-cancer date earlier than Carcinoma date (if Carcinoma date exists)
#         (df[date_carcinoma].notna() & (df[date_other_cancer] < df[date_carcinoma]))
#         |
#         # Carcinoma date absent, breast-cancer date exists, other-cancer date earlier
#         (df[date_carcinoma].isna() & df[date_breast_cancer].notna()
#          & (df[date_other_cancer] < df[date_breast_cancer]))
#         |
#         # both comparison dates absent
#         (df[date_carcinoma].isna() & df[date_breast_cancer].isna())
#     )
# )

# earliest_comp_date = df[[date_carcinoma, date_breast_cancer]].min(axis=1, skipna=True)
# mask_drop = (
#     # has other-cancer panel
#     (df[col_other_cancer_ep] == 1)
#     &
#     (
#         # Case A ─ both comparison dates missing  → drop outright
#         earliest_comp_date.isna()
#         |
#         # Case B ─ other-cancer date is earlier than *either* comparison date (the min)
#         (df[date_other_cancer] < earliest_comp_date)
#     )
# )

# df_filtered = df.loc[~mask_drop].copy()

col_breast_cancer_ep = "ep_diy_p1232015483_combined_ep"
col_carcinoma_ep = "ep_diy_p1781594777_combined_ep"
col_bc_prevalent = "breast_cancer_prevalent"


df[[col_breast_cancer_ep, col_carcinoma_ep]] = df[
    [col_breast_cancer_ep, col_carcinoma_ep]
].astype("Int64")

# earliest comparison date
earliest_comp_date = df[[date_carcinoma, date_breast_cancer]].min(axis=1, skipna=True)

mask_no_comparison_panels = (df[col_breast_cancer_ep].fillna(0) == 0) & (
    df[col_carcinoma_ep].fillna(0) == 0
)

mask_drop_core = (df[col_other_cancer_ep] == 1) & (  # has other-cancer panel
    earliest_comp_date.isna()  # ── Case A: both comparison dates missing
    | (
        df[date_other_cancer] < earliest_comp_date
    )  # ── Case B: other-cancer date earlier
    | mask_no_comparison_panels  # ── Case C: other-cancer panel present but
    #           neither comparison panel present
)

# make sure cases from breast cancer prevalent are not excluded
mask_bc_prev = df[col_bc_prevalent] == 1
mask_drop = mask_drop_core & (~mask_bc_prev)

df_filtered = df.loc[~mask_drop].copy()

outfile = "final_phenotype_file.txt"
df_filtered.to_csv(outfile, sep="\t", index=False)

print(f"Kept {df_filtered.shape[0]:,} of {df.shape[0]:,} rows. Saved to {outfile}.")

n_bc_filtered = (df_filtered["breast_cancer"] == 1).sum()
print(f"Entries with breast_cancer == 1 after filtering: {n_bc_filtered:,}")

###############################################################################
# Add information of breast cancer subtype
###############################################################################
csv_file = "DAR-2025-00079.breast_filtered_header_classification_ccvid.csv"
pheno_file = "final_phenotype_file.txt"
output_file = "final_phenotype_file_with_subtype.txt"

csv_df = pd.read_csv(csv_file)
pheno_df = pd.read_csv(pheno_file, sep="\t")

# select only the needed columns from the CSV
selected_columns = csv_df[
    ["ccvid", "is_er_positive_or_borderline", "is_er_negative", "is_triple_negative"]
]

# Merge: left join on pheno_df using FID = ccvid
merged_df = pheno_df.merge(
    selected_columns, how="left", left_on="FID", right_on="ccvid"
)

merged_df.drop(columns=["ccvid"], inplace=True)

# Drop rows where breast_cancer == 1 AND all subtype columns are NaN
condition = (merged_df["breast_cancer"] == 1) & merged_df[
    ["is_er_positive_or_borderline", "is_er_negative", "is_triple_negative"]
].isna().all(axis=1)

filtered_df = merged_df[~condition]  # Keep rows that do NOT meet the condition

# Save to output
filtered_df.to_csv(output_file, sep="\t", index=False)
print(f"Merged and filtered data saved to: {output_file}")

###############################################################################
# ER positive subtype
###############################################################################
input_file = "final_phenotype_file_with_subtype.txt"
output_file = "final_phenotype_file_ER_positive.txt"

df = pd.read_csv(input_file, sep="\t")

df_filtered = df[
    ~((df["breast_cancer"] == 1) & (df["is_er_positive_or_borderline"] != 1))
]

# rename column
df_filtered = df_filtered.rename(columns={"breast_cancer": "ER_positive_subtype"})

df_filtered = df_filtered.drop(
    columns=["is_er_positive_or_borderline", "is_er_negative", "is_triple_negative"],
    errors="ignore",
)

# Count how many ER-positive cases remain
num_cases = (df_filtered["ER_positive_subtype"] == 1).sum()
print(f"Number of ER-positive cases (ER_positive_subtype == 1): {num_cases}")

df_filtered.to_csv(output_file, sep="\t", index=False)
print(f"Filtered and renamed file saved to: {output_file}")

###############################################################################
# ER negative subtype
###############################################################################
input_file = "final_phenotype_file_with_subtype.txt"
output_file = "final_phenotype_file_ER_negative.txt"

df = pd.read_csv(input_file, sep="\t")

df_filtered = df[~((df["breast_cancer"] == 1) & (df["is_er_negative"] != 1))]

# rename column
df_filtered = df_filtered.rename(columns={"breast_cancer": "ER_negative_subtype"})

df_filtered = df_filtered.drop(
    columns=["is_er_positive_or_borderline", "is_er_negative", "is_triple_negative"],
    errors="ignore",
)

# Count how many ER-positive cases remain
num_cases = (df_filtered["ER_negative_subtype"] == 1).sum()
print(f"Number of ER-positive cases (ER_negative_subtype == 1): {num_cases}")

df_filtered.to_csv(output_file, sep="\t", index=False)
print(f"Filtered and renamed file saved to: {output_file}")


###############################################################################
# Triple negative subtype
###############################################################################
input_file = "final_phenotype_file_with_subtype.txt"
output_file = "final_phenotype_file_triple_negative.txt"

df = pd.read_csv(input_file, sep="\t")

df_filtered = df[~((df["breast_cancer"] == 1) & (df["is_triple_negative"] != 1))]

# rename column
df_filtered = df_filtered.rename(columns={"breast_cancer": "triple_negative_subtype"})
df_filtered = df_filtered.drop(
    columns=["is_er_positive_or_borderline", "is_er_negative", "is_triple_negative"],
    errors="ignore",
)

# Count how many triple negative cases remain
num_cases = (df_filtered["triple_negative_subtype"] == 1).sum()
print(f"Number of ER-positive cases (triple_negative_subtype == 1): {num_cases}")

df_filtered.to_csv(output_file, sep="\t", index=False)
print(f"Filtered and renamed file saved to: {output_file}")
