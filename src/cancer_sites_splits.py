import pandas as pd

phenotype_file = "filtered_women_only_combined_baseline_and_endpoints.txt"
pheno_data = pd.read_csv(phenotype_file, delim_whitespace=True)

non_na_count = pheno_data["cancer_site"].notna().sum()
print(f"Number of non-NA entries in cancer_site: {non_na_count}")

count_five = (pheno_data["cancer_site"] == 5).sum()
print(f"Number of entries with value 5 in cancer_site: {count_five}")

# Define cancer site mapping
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

print(f"Updated file with cancer site columns saved to {output_file}")
