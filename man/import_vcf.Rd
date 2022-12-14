% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IO.R
\name{import_vcf}
\alias{import_vcf}
\title{Import VCF from File}
\usage{
import_vcf(file = file, ...)

import_vcf(file = file, ...)
}
\arguments{
\item{file}{file path of VCF file}

\item{...}{pass to \code{vcfR::read.vcfR()}}
}
\value{
vcfR object
}
\description{
import *.vcf structured text format,
as well as the compressed \verb{*.vcf.gz} format.
}
\examples{

vcfPath <- system.file("extdata", "var.vcf.gz", package = "geneHapR")
vcf <- import_vcf(file = vcfPath)
vcf

}
\seealso{
\code{\link[vcfR:read.vcfR]{vcfR::read.vcfR()}}
}
\author{
Zhangrenl
}
