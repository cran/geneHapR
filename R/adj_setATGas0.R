#' @title Set Position of ATG as Zero
#' @name SetATGas0
#' @description
#' Set position of ATG as zero in hap result and gff annotation.
#' The upstream was negative while the gene range and downstream was positive.
#' @details
#' Filter hap result and gff annotation according to provided information.
#' And then set position of ATG as zero in hap result and gff annotation.
#' The upstream was negative while the gene range and downstream was positive.
#'
#' **Notice:** the position of "ATG" after modified was 0, 1 and 2 separately.
#' The site in hap result exceed the selected range will be **dropped**.
#' @usage
#' gffSetATGas0(gff = gff, hap = hap,
#'              geneID = geneID,
#'              Chr = Chr, POS = POS)
#' @param gff gene annotations
#' @param hap object of hapResult or hapSummary class
#' @param geneID geneID
#' @param Chr Chromsome name
#' @param POS vector consist with start and end position
#' @importFrom GenomicRanges strand
#' @examples
#' \donttest{
#' # load example dataset
#' data("geneHapR_test")
#'
#'
#' # set position of ATG as zero in gff
#' newgff <- gffSetATGas0(gff = gff, hap = hapResult,
#'                        geneID = "test1G0387",
#'                        Chr = "scaffold_1",
#'                        POS = c(4300, 7910))
#'
#' }
#' @return `gffSetATGas0`: filtered gff with position of ATG was as zero
#' @seealso
#' \code{\link[geneHapR:displayVarOnGeneModel]{displayVarOnGeneModel()}}
#' @export
gffSetATGas0 <- function(gff = gff,
                         hap = hap,
                         geneID = geneID,
                         Chr = Chr,
                         POS = POS) {
    if (missing(Chr)) {
        Chr <- hap[hap$Hap == "CHR", 2]
        warning("Chr is missing, will use: ", Chr)
    }
    if (missing(POS)) {
        POS <- hap[hap$Hap == "POS", ]
        POS <- suppressWarnings(as.numeric(POS))
        POS <- na.omit(POS)
        POS <- c(min(POS), max(POS))
        warning("POS is missing, will use: ", POS)
    } else {
        POS <- c(min(POS), max(POS))
    }

    tmp <- setATGas0(
        gff = gff,
        hap = hap,
        geneID = geneID,
        Chr = Chr,
        POS = POS
    )
    return(tmp$gff)
}


#' @name SetATGas0
#' @usage
#' hapSetATGas0(gff = gff, hap = hap,
#'              geneID = geneID,
#'              Chr = Chr, POS = POS)
#' @examples
#' data("geneHapR_test")
#'
#' # set position of ATG as zero in hap results
#' newhapResult <- hapSetATGas0(gff = gff, hap = hapResult,
#'                              geneID = "test1G0387",
#'                              Chr = "scaffold_1",
#'                              POS = c(4300, 7910))
#' @return `hapSetATGas0`: hap results with position of ATG was set as zero
#' @export
hapSetATGas0 <- function(gff = gff,
                         hap = hap,
                         geneID = geneID,
                         Chr = Chr,
                         POS = POS) {
    if (missing(Chr)) {
        Chr <- hap[hap$Hap == "CHR", 2]
        warning("Chr is missing, will use: ", Chr)
    }
    if (missing(POS)) {
        POS <- hap[hap$Hap == "POS", ]
        POS <- suppressWarnings(as.numeric(POS))
        POS <- na.omit(POS)
        POS <- c(min(POS), max(POS))
        warning("POS is missing, will use: ", POS)
    } else {
        POS <- c(min(POS), max(POS))
    }

    tmp <- setATGas0(
        gff = gff,
        hap = hap,
        geneID = geneID,
        Chr = Chr,
        POS = POS
    )
    hap <- tmp$hap
    return(hap)
}


setATGas0 <- function(gff = gff,
                      hap = hap,
                      geneID = geneID,
                      Chr = Chr,
                      POS = POS) {

    options <- attr(hap, "options")
    AccAll <- attr(hap, "AccAll")
    AccRemoved <- attr(hap, "AccRemoved")
    hap2acc <- attr(hap, "hap2acc")


    # filter gff by postion
    POSRange <- GenomicRanges::GRanges(seqnames = Chr,
                                       IRanges::IRanges(start = min(POS),
                                                        end = max(POS)))
    gffOver <- gff[gff %over% POSRange]

    # filter gff by geneID
    if (missing(geneID)) {
        stop("geneID is missing")
    } else {
        probe <- c()
        for(i in seq_len(length(gffOver$Parent))){
            if(length(gffOver$Parent[[i]]) == 0L) p <- FALSE else
                p <- stringr::str_detect(gffOver$Parent[[i]], geneID)
            probe <- c(probe, p)
        }
        gffOver <- gffOver[probe]
    }

    if(TRUE %in% probe == FALSE)
        stop("please check your input")
    # get position of ATG
    # filter gff by type: CDS
    gffCDS <- gffOver[gffOver$type == "CDS"]

    strd = GenomicRanges::strand(gffCDS)
    strd = unique(strd)
    if ("-" %in% strd & "+" %in% strd)
        stop("Can't decide Gene strand, please check your input")
    if (strd == "+") {
        POSatg <- min(IRanges::start(gffCDS))
    } else if (strd == "-") {
        POSatg <- max(IRanges::end(gffCDS))
    } else {
        stop("Can't decide Gene strand, please check your input")
    }

    # get postions for hap and gffOver
    newPOS <- suppressWarnings(as.numeric(hap[2, ]) - POSatg)
    starts <- IRanges::start(gffOver) - POSatg
    ends <- IRanges::end(gffOver) - POSatg

    # substitute postions in hap and gff
    if (strd == "-") {
        hap[2,-1] <- -newPOS[-1]
        # rename colnames of hap
        probe <-
            base::intersect(c("Accession", "freq"), colnames(hap))
        newColNam <- hap[2, c(2:(ncol(hap) - length(probe)))]
        colnames(hap)[c(2:(ncol(hap) - length(probe)))] <- newColNam
        # reorder cols of hap
        newOrd <- order(as.numeric(newColNam))
        newOrd <- newColNam[newOrd]
        names(newOrd) <- newOrd[1, ]
        firColNam <- colnames(hap)[1]
        lastColNam <-
            colnames(hap)[(ncol(hap) - length(probe) + 1):ncol(hap)]
        # message(paste(c(firColNam, names(newOrd), lastColNam),sep = "\t",collapse = " "))
        hap <- hap[, c(firColNam, names(newOrd), lastColNam)]

        IRanges::start(gffOver) <- -ends
        IRanges::end(gffOver) <- -starts
    } else {
        hap[2,-1] <- newPOS[-1]
        # rename colnames of hap
        probe <-
            base::intersect(c("Accession", "freq"), colnames(hap))
        newColNam <- hap[2, c(2:(ncol(hap) - length(probe)))]
        colnames(hap)[c(2:(ncol(hap) - length(probe)))] <- newColNam
        IRanges::start(gffOver) <- starts
        IRanges::end(gffOver) <- ends
    }
    GenomicRanges::strand(gffOver) <- "+"
    attr(hap, "options") <- options
    attr(hap, "AccAll") <- AccAll
    attr(hap, "AccRemoved") <- AccRemoved
    attr(hap, "AccRemain") <- AccAll[! AccAll %in% AccRemoved]
    attr(hap, "hap2acc") <- hap2acc
    attr(hap, "freq") <- table(names(hap2acc))
    return(list(gff = gffOver, hap = hap))
}

