Load required libraries
library(targets)
library(dotenv)
library(httr)
library(dplyr)
library(arrow)
library(base64enc)
library(R.utils)

# Load environment variables
dotenv::load_dot_env()

# Define functions
get_cosmic_encoded <- function() {
  cosmic_mail <- Sys.getenv("COSMIC_EMAIL")
  cosmic_pass <- Sys.getenv("COSMIC_PASSWORD")
  auth <- paste(
    "Basic", base64encode(
      charToRaw(paste(cosmic_mail, ":", cosmic_pass, sep = ""))
    )
  )
  return(auth)
}

download_cosmic_file <- function(url, output_path, filename, auth) {
  response <- GET(
    url, add_headers(Authorization = auth)
  )
  
  if (status_code(response) != 200) {
    stop("Failed to get the download link: ", status_code(response))
  }
  
  auth_content <- content(response)
  download_link <- auth_content$url
  
  file_path <- file.path(output_path, filename)
  download.file(download_link, destfile = file_path, method = "curl")
  return(file_path)
}

untar_file <- function(tar_file, output_path) {
  untar(tar_file, exdir = output_path)
  if (file.exists(tar_file)) {
    file.remove(tar_file)
    txt_files <- list.files(output_path, pattern = "\\.txt$", full.names = TRUE)
    if (length(txt_files) > 0) {
      file.remove(txt_files)
      cat("Text files deleted.\n")
    }
  } else {
    cat("Extraction failed, tar file not deleted.")
  }
}

gunzip_file <- function(output_path) {
  gz_files <- list.files(output_path, pattern = "\\.gz$", full.names = TRUE)
  if (length(gz_files) > 0) {
    gunzip(gz_files[1], destname = paste(output_path, "data.tsv", sep = ""), remove = TRUE)
  }
}