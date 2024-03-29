% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_preprocessbigVCF.R
\name{filterLargeVCF}
\alias{filterLargeVCF}
\title{Pre-process of Large VCF File(s)}
\usage{
filterLargeVCF(VCFin = VCFin, VCFout = VCFout,
                Chr = Chr,
                POS = NULL,
                start = start,
                end = end,
                override = TRUE)
}
\arguments{
\item{VCFin}{Path of input \verb{*.vcf/*.vcf.gz} file.}

\item{VCFout}{Path(s) of output \verb{*.vcf/*.vcf.gz} file.}

\item{Chr}{a single CHROM name or CHROM names vector.}

\item{POS, start, end}{provide the range should be extract from orignal vcf.
\code{POS}: a vector consist with start and end position or a list
with length equal to \code{Chr}, eg.: \code{list(c(1,200), c(300,500), c(300,400))}
indicates 3 ranges (1~200, 300~500 and 300~400).
if \code{POS} is \code{NULL}, \code{start} and \code{end} are needed, eg.:
\code{start = c(1, 30)} and \code{end = c(200, 150)} indicates 2 ranges
(1~200 and 30~150)}

\item{override}{whether override existed file or not, default as \code{TRUE}.}
}
\value{
No return value
}
\description{
Filter/extract one or multiple gene(s)/range(s) from a large
\verb{*.vcf/*.vcf.gz} file.
}
\details{
This package import VCF files with 'vcfR' which is more efficient to
import/manipulate VCF files in 'R'. However, import a large VCF file is time and
memory consuming. It's suggested that filter/extract variants in target
range with \code{filterLargeVCF()}.

When filter/extract multi genes/ranges, the parameter of \code{Chr} and \code{POS}
must have equal length. Results will save to a single file if the user
provide a single file path or save to multiple VCF file(s) when a equal length
vector consist with file paths is provided.

However, if you have hundreds gene/ranges need to extract from very
large VCF file(s), it's prefer to process with other linux tools in a script
on server, such as: 'vcftools' and 'bcftools'.
}
\examples{
\donttest{
 # The filteration of small vcf should be done with `filter_vcf()`.
 # however, here, we use a mini vcf instead just for example and test.

 vcfPath <- system.file("extdata", "var.vcf.gz", package = "geneHapR")

 oldDir <- getwd()
 temp_dir <- tempdir()
 if(! dir.exists(temp_dir))
   dir.create(temp_dir)
 setwd(temp_dir)
 # extract a single gene/range from large vcf
 filterLargeVCF(VCFin = vcfPath, VCFout = "filtered.vcf.gz",
                Chr = "scaffold_1", POS = c(4300,5000), override = TRUE)

 # extract multi genes/ranges from large vcf
 filterLargeVCF(VCFin = vcfPath,
                VCFout = c("filtered1.vcf.gz",
                           "filtered2.vcf.gz",
                           "filtered3.vcf.gz"),
                Chr = rep("scaffold_1", 3),
                POS = list(c(4300, 5000),
                           c(5000, 6000),
                           c(5000, 7000)),
                override = TRUE)

setwd(oldDir)
}
}
