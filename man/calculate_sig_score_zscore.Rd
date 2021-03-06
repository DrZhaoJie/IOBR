% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_sig_score.R
\name{calculate_sig_score_zscore}
\alias{calculate_sig_score_zscore}
\title{Calculating signature score using z-score method}
\usage{
calculate_sig_score_zscore(
  pdata = NULL,
  eset,
  signature,
  mini_gene_count,
  column_of_sample,
  adjust_eset = FALSE
)
}
\arguments{
\item{pdata}{phenotype data of input sample;
if phenotype data is NULL, create a data frame with `Index` and `ID` contain column names of eset}

\item{eset}{normalizaed  transcriptomic data: normalized (CPM, TPM, RPKM, FPKM, etc.)}

\item{signature}{List of gene signatures}

\item{mini_gene_count}{filter out signatures with genes less than minimal gene in expression set;}

\item{column_of_sample}{Defines in which column of pdata the sample identifier can be found}

\item{adjust_eset}{remove variables with missing value, sd =0, and Inf value}
}
\value{
data frame with pdata and signature scores for gene sets; signatures in columns, samples in rows
}
\description{
Calculating signature score using z-score method
}
\examples{

}
\author{
Dongqiang Zeng
}
