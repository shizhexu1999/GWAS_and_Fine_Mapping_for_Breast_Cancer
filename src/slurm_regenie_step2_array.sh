#!/bin/bash

# Specify a job name
#SBATCH -J regenie_step2

# Account name and target partition
#SBATCH -A ckb.prj
#SBATCH -p short

# Log locations which are relative to the current
# working directory of the submission
#SBATCH -o regenie_step2.%j_%a.out
#SBATCH -e regenie_step2.%j_%a.err

#SBATCH -D /well/ckb-share/gwas_breast_cancer_confluence/chr6_Dec_6

# Set up the array for chromosomes 1 through 23
#SBATCH --array=1-23

# Parallel environment settings
#  For more information on these please see the documentation
#  Allowed parameters:
#   -c, --cpus-per-task
#   -N, --nodes
#   -n, --ntasks
#SBATCH -c 1

# Some useful data about the job to help with debugging
echo "------------------------------------------------"
echo "Slurm Job ID: $SLURM_JOB_ID"
echo "Array Task ID: $SLURM_ARRAY_TASK_ID (Chromosome)"
echo "Run on host: "`hostname`
echo "Operating system: "`uname -s`
echo "Username: "`whoami`
echo "Started at: "`date`
echo "------------------------------------------------"

# Begin writing your script here

echo $SLURM_JOB_ID

module purge
module load Regenie/4.0-GCC-12.3.0

# Set the chromosome variable based on the array task ID
CHROM=${SLURM_ARRAY_TASK_ID}

regenie \
  --step 2 \
  --bgen /well/ckb-share/CKB_imputed_v2.0_b38/CKB_imputed_v2_b38_chr${CHROM}.bgen \
  --sample /well/ckb-share/CKB_imputed_v2.0_b38/23_gsid.sample \
  --covarFile /well/ckb-share/gwas_breast_cancer_confluence/Dec_3/updated_covariate_file_regenie.txt \
  --covarColList region_code,age_at_study_date_x100,national_pc01,national_pc02,national_pc03,national_pc04,national_pc05,national_pc06,national_pc07,national_pc08,national_pc09,national_pc10,national_pc11 \
  --catCovarList region_code \
  --phenoFile /well/ckb-share/gwas_breast_cancer_confluence/Dec_3/final_filtered_women_only_combined_baseline_and_endpoints_with_breast_cancer.txt \
  --phenoColList breast_cancer \
  --bsize 500 \
  --bt \
  --firth --approx \
  --pred /well/ckb-share/gwas_breast_cancer_confluence/Dec_6/fit_bin_out_pred.list \
  --out test_bin_out_firth_chr${CHROM}

# End of job script
