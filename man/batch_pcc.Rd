% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/batch_pcc.R
\name{batch_pcc}
\alias{batch_pcc}
\title{Batch way to calculate the partial correlation coefficient}
\usage{
batch_pcc(
  pdata_group,
  id1 = "ID",
  feature_data,
  id2 = "ID",
  interferenceid,
  target,
  method = "pearson"
)
}
\arguments{
\item{pdata_group}{matrix;data signature matrix with multiple features}

\item{interferenceid}{character vectors; vector used to control}

\item{target}{character vectors; target name of group}

\item{method}{vector; one of "pearson"(default), "spearman" or "kendall"}
}
\value{

}
\description{
batch_pcc() provide a batch way to calculate the partial correlation coefficient between target gene and others when
controlling a third variable
}
\examples{
pdata_group <- imvigor210_pdata[, c("ID", "TumorPurity", "Pan_F_TBRs")] \%>\%
rename(target = Pan_F_TBRs) \%>\% mutate(target = as.numeric(target))
res <- batch_pcc(pdata_group = pdata_group, id1 = "ID", feature_data = imvigor210_sig,
id2 = "ID", interferenceid = "TumorPurity",
target = "target", method = "pearson")
}
\author{
Rongfang Shen
}
