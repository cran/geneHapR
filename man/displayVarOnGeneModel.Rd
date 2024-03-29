% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vis_hapVisualization.R
\name{displayVarOnGeneModel}
\alias{displayVarOnGeneModel}
\title{Display Variants on Gene Model}
\usage{
displayVarOnGeneModel(
  hapSummary,
  gff,
  Chr,
  startPOS,
  endPOS,
  type = "pin",
  cex = 0.7,
  CDS_h = 0.05,
  fiveUTR_h = 0.02,
  threeUTR_h = 0.01,
  geneElement = geneElement,
  hap
)
}
\arguments{
\item{hapSummary, hap}{haplotype result}

\item{gff}{gff}

\item{Chr}{the chromosome name.
If missing, the first element in the hapSummary will be used}

\item{startPOS}{If missing, will use the min position in hapSummary}

\item{endPOS}{If missing, will use the max position in hapSummary}

\item{type}{character. Could be "circle", "pie", "pin",
"pie.stack" or "flag"}

\item{cex}{a numeric control the size of circle}

\item{CDS_h, fiveUTR_h, threeUTR_h}{The height of CDS 5'UTR and 3'UTR
in gene model}

\item{geneElement}{ploted elements, eg.: c("CDS","five_prime_UTR")}
}
\value{
No return value
}
\description{
show variants on gene model using hapSummary and gene annotations
}
\examples{
\donttest{
data("geneHapR_test")
hapSummary <- hap_summary(hapResult)
displayVarOnGeneModel(hapSummary, gff,
                      startPOS = 4100,
                      endPOS = 8210,
                      cex = 0.75)
}
}
