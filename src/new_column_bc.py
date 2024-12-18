import pandas as pd

file_path = "updated_filtered_women_only_combined_baseline_and_endpoints.txt"
df = pd.read_csv(file_path, sep="\t")

df["breast_cancer_prevalent"] = (
    (df["cancer_diag"] == 1) & (df["cancer_Breast"] == 1)
).astype(int)

df["breast_cancer"] = (
    (df["breast_cancer_prevalent"] == 1) | (df["ep_diy_p1232015483_combined_ep"] == 1)
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
