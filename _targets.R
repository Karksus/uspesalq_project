# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(qs)
library(fst)
library(crew)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c(
    "dplyr",
    "data.table",
    "arrow",
    "httr",
    "jsonlite",
    "stringr",
    "biomaRt",
    "org.Hs.eg.db",
    "depmap",
    "purrr"
  ),
  #controller = crew_controller_local(workers = 3, seconds_idle = 3),
  memory = "transient",
  garbage_collection = TRUE
  # Packages that your targets need for their tasks.
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("R/")
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(
    targeted_data,
    get_cosmic_target_data("data/Cosmic_CompleteTargetedScreensMutant_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    wgs_data,
    get_cosmic_wgs_data("data/Cosmic_GenomeScreensMutant_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    classification_data,
    load_classification_data("data/Cosmic_Classification_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    cgc_data,
    load_cgc_data("data/Cosmic_CancerGeneCensus_v99_GRCh37.tsv"),
    format = "qs"
  ),
  tar_target(
    hallmarks_data,
    load_hallmarks_data(
      "data/Cosmic_CancerGeneCensusHallmarksOfCancer_v99_GRCh37.tsv"
    ),
    format = "qs"
  ),
  tar_target(
    targeted_classify,
    join_targeted_classification(targeted_data, classification_data),
    format = "qs"
  ),
  tar_target(
    wgs_classify,
    join_wgs_classification(wgs_data, classification_data),
    format = "qs"
  ),
  tar_target(
    targeted_counts,
    calculate_targeted_counts(targeted_classify),
    format = "qs"
  ),
  tar_target(
    wgs_total_counts,
    calculate_wgs_counts(wgs_classify),
    format = "qs"
  ),
  tar_target(
    merged_counts,
    merge_counts(targeted_counts, wgs_total_counts),
    format = "qs"
  ),
  tar_target(cosmic_gene_frequency,
             calculate_cosmic_frequency(merged_counts),
             format = "fst_dt"),
  tar_target(entrez_gene_data,
             get_entrez_gene_data(),
             format = "qs"),
  tar_target(
    pubmed_gene_citations,
    load_and_format_pubmed_data("data/pubmed_citation_count.csv"),
    format = "qs"
  ),
  tar_target(
    entrez_pubmed_merged,
    merge_entrez_pubmed(pubmed_gene_citations, entrez_gene_data),
    format = "qs"
  ),
  tar_target(
    gene_list,
    final_gene_list(entrez_pubmed_merged),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    clinicaltrials_gene_count,
    load_clinicaltrials_data("data/clinical_trials_data.csv"),
    deployment = "main",
    format = "qs"
    ),
  tar_target(
    annotated_clinicaltrials_data,
    annotate_clinicaltrials_data(clinicaltrials_gene_count, entrez_gene_data),
    deployment = "main",
    format = "qs"
  ),
  tar_target(depmap_crispr_data,
             load_depmap_crispr_data(),
             format = "qs"),
  tar_target(pivot_wider_depmap_crispr,
             depmap_crispr_site_to_column(depmap_crispr_data),
             format = "qs"),
  tar_target(depmap_rnai_data,
             load_depmap_rnai_data(),
             format = "qs"),
  tar_target(pivot_wider_depmap_rnai,
             depmap_rnai_site_to_column(depmap_rnai_data),
             format = "qs"),
  tar_target(
    oncokb_data,
    get_oncokb_data(
      "https://www.oncokb.org/api/v1/utils/allCuratedGenes?includeEvidence=true"
    ),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    formatted_oncokb,
    format_oncokb_data(oncokb_data),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    annotated_cosmic_freq_data,
    annotate_cosmic_freq_data(cosmic_gene_frequency, entrez_gene_data),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    merged_cosmic_freq_cgc,
    merge_cosmic_freq_cgc(annotated_cosmic_freq_data, cgc_data),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    merged_cosmic_freq,
    merge_cosmic_freq_hallmarks(merged_cosmic_freq_cgc, hallmarks_data),
    deployment = "main",
    format = "qs"
  ),
  tar_target(
    pivot_wider_cosmic,
    cosmic_site_to_column(merged_cosmic_freq),
    deployment = "main",
    format = "qs"
  )
)
