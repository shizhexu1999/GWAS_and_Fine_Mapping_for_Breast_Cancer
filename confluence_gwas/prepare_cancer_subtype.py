"""
Generate breast cancer subtype classifications, distinguishing ER-positive,
ER-negative, and triple-negative cases.

Required Python packages: pandas, numpy
Author: Shizhe Xu
Date: 09 July 2025
"""

###############################################################################
# Since each row of the original file contains 'breast', and then we filter out
# the primary site containing 'breast'
###############################################################################

import pandas as pd

file_path = "/well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/DAR-2025-00079.breast_filtered_header.csv"

df = pd.read_csv(file_path)

# filter out rows where 'primary_site' is 'breast'
filtered_df = df[df["primary_site"] == "Breast"]

# save the filtered dataframe
filtered_df.to_csv(
    "DAR-2025-00079.breast_filtered_header_primary_breast.csv", index=False
)

###############################################################################
# Convert each strong, weak and borderline status into numerical values
###############################################################################
import numpy as np

file_path = "DAR-2025-00079.breast_filtered_header_primary_breast.csv"

df = pd.read_csv(file_path)


# conditions = [
#     # Condition 1: ER is strongly or weakly or borderline positive
#     (df['status_er'].isin(['Strong positive (++/+++)', 'Weak positive (+)', 'Borderline result (+/-)'])),
#     # # Condition 2: PR is strongly or weakly positive or borderline
#     # (df['status_pr'].isin(['Strong positive (++/+++)', 'Weak positive (+)', 'Borderline result (+/-)'])),
#     # Condition 2: ER is negative
#     (df['status_er'] == 'Negative (-)'),
#     # Condition 3: Triple-negative
#     (df['status_pr'] == 'Negative (-)') & (df['status_er'] == 'Negative (-)') & (df['status_c_erbb2'] == 'Negative (-)'),
#     # # Condition 4: Both are unknown or missing (NaN)
#     # (df['status_er'].isin(['Unknown', np.nan]) & df['status_pr'].isin(['Unknown', np.nan]))
# ]

# # define corresponding values for the conditions
# values = [1, -1, 0, np.nan]

# apply conditions to create the new column
# df['positive_er_pr_subtype'] = np.select(conditions, values, default=0)

# Condition 1: ER is strongly, weakly, or borderline positive
df["is_er_positive_or_borderline"] = (
    df["status_er"]
    .isin(["Strong positive (++/+++)", "Weak positive (+)", "Borderline result (+/-)"])
    .astype(int)
)

# Condition 2: ER is negative
df["is_er_negative"] = (df["status_er"] == "Negative (-)").astype(int)

# Condition 3: Triple-negative (ER, PR, and HER2 all negative)
# note that only the top category should be considered as positive for HER2
df["is_triple_negative"] = (
    (df["status_er"] == "Negative (-)")
    & (df["status_pr"] == "Negative (-)")
    & (
        df["status_c_erbb2"].isin(
            ["Negative (-)", "Borderline result (+/-)", "Weak positive (+)"]
        )
    )
).astype(int)

df.to_csv("DAR-2025-00079.breast_filtered_header_classification.csv", index=False)
