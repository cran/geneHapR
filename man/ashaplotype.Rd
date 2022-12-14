% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vis_network.R
\name{ashaplotype}
\alias{ashaplotype}
\alias{as.haplotype}
\title{as.haplotype}
\usage{
as.haplotype(hap)
}
\arguments{
\item{hap}{object of \code{hapSummary} or \code{hapResult} class}
}
\value{
haplotype class
}
\description{
convert \code{hapSummary} or \code{hapResult} class into \code{haplotype} class (pegas)
}
\note{
It's not advised for \code{hapSummary} or \code{hapResult} with indels, due to indels will
convert to SNPs with equal length of each indel.
}
\examples{
data("geneHapR_test")
hap <- as.haplotype(hapResult)
hapSummary <- hap_summary(hapResult)
hap <- as.haplotype(hapSummary)
}
