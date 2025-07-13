**********************************************
# **GWAS and Fine-Mapping for Breast Cancer**
**********************************************

## Summary
This repository contains code and scripts to uncover putative causal variants for breast cancer through GWAS and fine-mapping.

## Study Objectives
- We conducted a GWAS analysis to identify genetic susceptibilities for overall breast cancer and its subtype (ER positive, ER negative and triple negative) using the China Kadoorie Biobank (CKB) dataset. The GWAS summary statistics will be contributed to the **Confluence** project, which is collaboration among breast cancer consortia to conduct the largest and most diverse breast cancer GWAS to date.
- We applied and compared various fine-mapping methods to evaluate their performance, including conducting multi-ancestry analyses.  Evaluation metrics included credible set sizes and posterior inclusion probabilities (PIP).
- We conducted downstream analysis such as the polygenic risk score (PRS) and heritability estimation, and explored associations between PRS and other omic data, including proteomics.
- We investigated the integration of fine-mapping with machine learning frameworks to enhance the identification of causal variants.

## GWAS for the Confluence Project
The GWAS analysis was carried out with **REGENIE**, following the Confluence project’s recommended pipeline. The details of the CKB dataset and the number of breast cancer cases can found in [summary report](summary_cases_confluence_13_May.pdf).

To enable a robust comparison with **REGENIE**, we also applied another GWAS tool, **SAIGE**.

## Fine-Mapping
Alongside applying established fine-mapping methods in our simulation study, we propose a new fine-mapping approach based on machine learning.

## Roadmap

## Next Step

## Acknowledgement

## License
This project is licensed under the MIT license.

## Author
Shizhe Xu, shizhe.xu@ndph.ox.ac.uk

## Date
December 2024
