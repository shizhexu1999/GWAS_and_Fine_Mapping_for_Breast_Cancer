#!/bin/bash

# Specify a job name
#SBATCH -J regenie_step1

# Account name and target partition
#SBATCH -A ckb.prj
#SBATCH -p short

# Log locations which are relative to the current
# working directory of the submission
#SBATCH -o regenie_step1.%j.out
#SBATCH -e regenie_step1.%j.err

#SBATCH -D /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence

# Parallel environment settings
#  For more information on these please see the documentation
#  Allowed parameters:
#   -c, --cpus-per-task
#   -N, --nodes
#   -n, --ntasks
#SBATCH -c 10

# Some useful data about the job to help with debugging
echo "------------------------------------------------"
echo "Slurm Job ID: $SLURM_JOB_ID"
echo "Run on host: "`hostname`
echo "Operating system: "`uname -s`
echo "Username: "`whoami`
echo "Started at: "`date`
echo "------------------------------------------------"

echo $SLURM_JOB_ID

module purge
module load Regenie/4.0-GCC-12.3.0

regenie --step 1 \
  --bed /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/array_data_qc.pruned \
  --extract /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/array_data_qc.snplist \
  --keep /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/array_data_qc.id \
  --phenoFile /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/final_phenotype_file.txt \
  --phenoColList breast_cancer \
  --covarFile /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/filtered_covariate_file_regenie_with_subset.txt \
  --covarColList national_pc01,national_pc02,national_pc03,national_pc04,national_pc05,national_pc06,national_pc07,national_pc08,national_pc09,national_pc10 \
  --strict \
  --bsize 1000 --bt \
  --lowmem --lowmem-prefix /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/tmp_rg \
  --gz --threads 8 \
  --use-relative-path \
  --out /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/regenie_step1_out \
  --loocv
