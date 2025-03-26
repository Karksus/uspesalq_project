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
