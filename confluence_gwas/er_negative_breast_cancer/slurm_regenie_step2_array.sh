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

#SBATCH -D /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_10_regenie_all_chromosomes_er_negative

# Set up the array for chromosomes 1 through 23
#SBATCH --array=1-23

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
echo "Array Task ID: $SLURM_ARRAY_TASK_ID (Chromosome)"
echo "Run on host: "`hostname`
echo "Operating system: "`uname -s`
echo "Username: "`whoami`
echo "Started at: "`date`
echo "------------------------------------------------"

echo $SLURM_JOB_ID

module purge
module load Regenie/4.0-GCC-12.3.0

# Set the chromosome variable based on the array task ID
CHROM=${SLURM_ARRAY_TASK_ID}


regenie --step 2 \
  --bgen /well/ckb-share/CKB_imputed_v2.0_b38/CKB_imputed_v2_b38_chr${CHROM}.bgen \
  --sample /well/ckb-share/CKB_imputed_v2.0_b38/23_gsid.sample \
  --phenoFile /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/final_phenotype_file_ER_negative.txt \
  --phenoColList ER_negative_subtype \
  --bsize 400 \
  --pred /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_10_regenie_all_chromosomes_er_negative/regenie_step1_out_pred.list \
  --threads 8 \
  --minMAC 30 --minINFO 0.2 \
  --bt --firth --approx \
  --test additive \
  --gz\
  --covarFile /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_6_regenie_confluence/filtered_covariate_file_regenie_with_subset.txt \
  --covarColList national_pc01,national_pc02,national_pc03,national_pc04,national_pc05,national_pc06,national_pc07,national_pc08,national_pc09,national_pc10 \
  --strict \
  --af-cc \
  --out /well/ckb/users/kws917/gwas_breast_cancer_confluence/July_10_regenie_all_chromosomes_er_negative/chr${CHROM}_out
