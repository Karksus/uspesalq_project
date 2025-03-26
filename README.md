## About the project

This project was developed with the aim to adress some of the challenges of integrating genomic data from various cancer-related databases. Collecting genomic data from multiple sources, we extracted a probability scoring model for gene-cancer associations. The scoring model, based on the Elastic Net algorithm, provides researchers with a ranked list of genes likely to be associated with cancer. Additionally, an [R package](https://github.com/Karksus/cancRscore) has been developed to facilitate easy querying and analysis of the generated data.

## Data Sources

The genomic data utilized in this project has been sourced from:

- TCGA [(The Cancer Genome Atlas)](https://portal.gdc.cancer.gov/)
- GTEx [(Genotype-Tissue Expression Project)](https://www.gtexportal.org/home/)
- COSMIC [(Catalogue of Somatic Mutations in Cancer)](https://cancer.sanger.ac.uk/cosmic)
- DepMap [(Cancer Dependency Map)](https://depmap.org/portal/)
- [ClinicalTrials](https://clinicaltrials.gov/)
- [PubMed](https://pubmed.ncbi.nlm.nih.gov/)

## Project structure

All the project ELT pipelines were builted and managed with the Targets R Package. Each data source was loaded, filtered and formatted whitin its unique pipeline, as well as the Elastic Net model preparation and extraction.

The pipeline logic is divided in this repo with the following componentes:

- `R` folder: Holds all the functions used in the pipelines, basically, it is where all the ETL code logic is stored.
- `scripts` folder: Holds some of the side scripts use to extract some of the data used in the project. It is not used in the actual pipeline, but users may find it useful.
- `store_` folders: holds Targets pipeline metadata. There is one "store" folder for each data source.
- `target_` R scripts: Holds the Targets R package logic for each ETL pipeline run.
- `projects_config.R: Sets all Targets configuration needed for this project. Running it will generate the `_targets.yaml`.
-  
