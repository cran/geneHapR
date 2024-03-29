% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vis_functionalSites.R
\name{plotEFF}
\alias{plotEFF}
\title{plotEFF}
\usage{
plotEFF(
  siteEFF,
  gff = gff,
  Chr = Chr,
  start = start,
  end = end,
  showType = c("five_prime_UTR", "CDS", "three_prime_UTR"),
  CDS.height = CDS.height,
  cex = 0.1,
  col = c("red", "yellow"),
  pch = 20,
  main = main,
  legend.cex = 0.8,
  gene.legend = TRUE,
  markMutants = TRUE,
  mutants.col = 1,
  mutants.type = 1,
  y = c("pvalue", "effect"),
  ylab = ylab,
  legendtitle = legendtitle,
  par.restore = TRUE
)
}
\arguments{
\item{siteEFF}{matrix, column name are pheno names and row name are site position}

\item{gff}{gff annotation}

\item{Chr}{the chromosome name}

\item{start}{start position}

\item{end}{end position}

\item{showType}{character vector, eg.: "CDS", "five_prime_UTR",
"three_prime_UTR"}

\item{CDS.height}{numeric indicate the height of CDS in gene model,
range: \verb{[0,1]}}

\item{cex}{a numeric control the size of point}

\item{col}{vector specified the color bar}

\item{pch}{vector controls points type, see
\code{\link[graphics:par]{par()}}}

\item{main}{main title}

\item{legend.cex}{a numeric control the legend size}

\item{gene.legend}{whether add legend for gene model}

\item{markMutants}{whether mark mutants on gene model, default as \code{TRUE}}

\item{mutants.col}{color of lines which mark mutants}

\item{mutants.type}{a vector of line types}

\item{y, ylab, legendtitle}{\emph{y:} indicate either pvalue or effect should be used as y axix,
\strong{ylab,legendtitle:},character, if missing, the value will be decide by y.}

\item{par.restore}{default as \code{TRUE}, wether restore the origin par after ploted EFF.}
}
\value{
No return value, called for side effects
}
\description{
plotEFF
}
\examples{
\donttest{
data("geneHapR_test")

# calculate site functional effect
# siteEFF <- siteEFF(hapResult, pheno, names(pheno))
# plotEFF(siteEFF, gff = gff, Chr = "scaffold_1")
}
}
