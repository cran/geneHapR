# @title Calculation of Sites Effective
# @name calcuSiteEffect
# @importFrom mrMLM ReadData inputData FASTmrMLM mrMLMFun
# @export
# calcuSiteEffect <- function(hap, pheno, phenoNames = names(pheno), quality = FALSE,
#                             method = c("mrMLM","FASTmrMLM","FASTmrEMMA","pLARmEB","pKWmEB"),
#                             p.adj = "none"){
#     Allmethod <- c("mrMLM", "FASTmrMLM", "FASTmrEMMA",
#                    "pLARmEB", "pKWmEB", "ISIS EM-BLASSO")
#     if(!(method %in% Allmethod)){
#         warning(
#         "method should be in 'mrMLM', 'FASTmrMLM', 'FASTmrEMMA',
# 'pLARmEB', 'pKWmEB', 'ISIS EM-BLASSO'")
#     }
#
#     if(length(method) > 1){
#         method <- method[1]
#     }
#
#     # format of genotype
#     hmp = hap2hmp(hap)
#     hmp = rbind(names(hmp),hmp)
#
#
#     EFF <- p.value <- hmp[-1,3:4]
#     ind.names <- row.names(pheno)
#     for(p in names(pheno)){
#         # format of Pheno
#         pheno.p <- pheno[, c(p)]
#         pheno.p <- cbind(ind.names, pheno.p)
#         pheno.p <- rbind(c("<Phenotype>", p), pheno.p)
#         pheno.p <- data.frame(pheno.p)
#         head(pheno.p)
#         Readraw=mrMLM::ReadData(fileGen=hmp,filePhe=data.frame(pheno.p),fileKin=NULL,filePS =NULL,
#                                 Genformat=3)
#         if ("FASTmrMLM" %in% method) { # FAIL
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="FASTmrMLM",trait=1)
#             result=mrMLM::FASTmrMLM(InputData$doMR$gen,InputData$doMR$phe,
#                              InputData$doMR$outATCG,InputData$doMR$genRaw,
#                              InputData$doMR$kk,InputData$doMR$psmatrix,0.01,svrad=20,
#                              svmlod=3,Genformat=3,CLO=1)
#         }
#         if ("mrMLM" %in% method){
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="mrMLM",trait=1)
#             result=mrMLM::mrMLMFun(InputData$doMR$gen,InputData$doMR$phe,InputData$doMR$outATCG,
#                             InputData$doMR$genRaw,InputData$doMR$kk,InputData$doMR$psmatrix,
#                             0.01,svrad=20,svmlod=3,Genformat=3,CLO=1)
#         }
#         if ("FASTmrEMMA" %in% method) {
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="FASTmrEMMA",trait=1)
#             result=mrMLM::FASTmrEMMA(InputData$doFME$gen,InputData$doFME$phe,
#                               InputData$doFME$outATCG,InputData$doFME$genRaw,
#                               InputData$doFME$kk,InputData$doFME$psmatrix,0.005,
#                               svmlod=3,Genformat=3,Likelihood="REML",CLO=1)
#         }
#         if ( "pLARmEB" %in% method){
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="pLARmEB",trait=1)
#             result=mrMLM::pLARmEB(InputData$doMR$gen,InputData$doMR$phe,InputData$doMR$outATCG,
#                            InputData$doMR$genRaw,InputData$doMR$kk,InputData$doMR$psmatrix,
#                            CriLOD=3,lars1=20,Genformat=3,Bootstrap=FALSE,CLO=1)
#         }
#         if ("pKWmEB" %in% method) {
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="pKWmEB",trait=1)
#             result=mrMLM::pKWmEB(InputData$doMR$gen,InputData$doMR$phe,InputData$doMR$outATCG,
#                           InputData$doMR$genRaw,InputData$doMR$kk,InputData$doMR$psmatrix,
#                           0.05,svmlod=3,Genformat=3,CLO=1)
#         }
#         if ("ISIS EM-BLASSO" %in% method) {
#             InputData=mrMLM::inputData(readraw=Readraw,Genformat=3,method="ISIS EM-BLASSO",
#                                 trait=1)
#             result=mrMLM::ISIS(InputData$doMR$gen,InputData$doMR$phe,InputData$doMR$outATCG,
#                         InputData$doMR$genRaw,InputData$doMR$kk,InputData$doMR$psmatrix,
#                         0.01,svmlod=3,Genformat=3,CLO=1)
#         }
#         EFF <- cbind(EFF, result$result1[,4])
#         p.value <- cbind(p.value, result$result1[,5])
#     }
#     return(list(p = p.value, EFF = EFF))
# }







#' @name siteEFF
#' @title Calculation of Sites Effective
#' @param hap object of "hapResult" class
#' @param pheno phenotype data, with column names as pheno name
#' and row name as accessions.
#' @param phenoNames pheno names used for analysis, if missing,
#' will use all pheno names in `pheno`
#' @param quality bool type, indicate whther the type of phenos are quality or
#' quantitative. Length of `quality` could be 1 or equal with length of
#' `phenoNames`. Default as `FALSE`
#' @param method character or character vector with length equal with
#' `phenoNames` indicate which method should be performed towards each
#' phenotype. Should be one of "t.test", "chi.test", "wilcox.test" and "auto".
#' Default as "auto", see details.
#' @param p.adj character, indicate correction method.
#' Could be "BH", "BY", "none"
#' @details
#' The site **EFF** was determinate by the phenotype difference between each
#' site geno-type.
#'
#' The *p* was calculated with statistical analysis method as designated by the
#' parameter `method`. If `method` set as "auto", then
#' chi.test will be
#' selected for quantity phenotype, eg.: color;
#' for quantity phynotype, eg.: height, with at least 30 observations per
#' geno-type and fit Gaussian distribution t.test will be performed, otherwise
#' wilcox.test will be performed.
#'
#'
#' @return a list containing two matrix names as "p" and "EFF",
#' with column name are pheno names and row name are site position.
#' The matrix names as "p" contains all *p*-value.
#' The matrix named as "EFF" contains scaled difference between each geno-types
#' per site.
#' @importFrom stats t.test chisq.test p.adjust shapiro.test wilcox.test
#' @usage
#' siteEFF(hap, pheno, phenoNames, quality = FALSE, method = "auto",
#'         p.adj = "none")
#' @examples
#' \donttest{
#' data("geneHapR_test")
#'
#' # calculate site functional effect
#' # siteEFF <- siteEFF(hapResult, pheno, names(pheno))
#' # plotEFF(siteEFF, gff = gff, Chr = "scaffold_1")
#' }
#' @export
siteEFF <- function(hap, pheno, phenoNames, quality = FALSE, method = "auto",
                    p.adj = "none"){
    message(
        # "This function has beed detached, please use 'calcuSiteEffect()' instead."
        "\u6CE8\u610F\uFF1A\u4F4D\u70B9\u6548\u5E94\u8BA1\u7B97\u672A\u8FDB",
        "\u884C\u7FA4\u4F53\u7ED3\u6784\u6821\u6B63\uFF0C\u6B64\u90E8\u5206",
        "\u7ED3\u679C\u4EC5\u4F9B\u53C2\u8003\uFF01"
    )
    Chr = hap[1,2]
    if(missing(phenoNames)) phenoNames <- names(pheno)
    m <- "'quality' length should be equal with 'phenoNames'"
    if(length(quality) == 1)
        quality <- rep(quality, length(phenoNames)) else
            stopifnot("'quality' length should be equal with 'phenoNames'" =
                          length(quality[1:10]) == length(phenoNames))
    names(quality) <- phenoNames

    if(!inherits(hap, "hapResult"))
        stop("hap should be object of 'hapResult' class")

    # get positions
    POS <- hap[hap$Hap == "POS",]
    POS <- suppressWarnings(as.numeric(POS))
    POS <- POS[! is.na(POS)]

    # extract genotype data
    hapData <- hap[! hap$Hap %in% c("POS","CHR","ALLELE","INFO"),]


    # get accession list
    accessions <- hapData[,names(hapData) == "Accession"]

    # preset of results
    results.p <- data.frame()
    results.d <- data.frame()

    echo <- FALSE
    t <- Sys.time()
    # processing
    for(phynoname in phenoNames){
        # whether echo pheno name
        # if(echo) cat("\n\t", phynoname) else {
        #     if(t){
        #         if((Sys.time() - t) > 5)
        #             echo <- TRUE
        #         t <- FALSE
        #     }
        # }


        # is.quality
        is.quality <- quality[phynoname]

        # scale phenos if not quality
        pheno.n <- pheno[, phynoname]
        if(!is.quality) pheno.n <- pscale(pheno.n)
        names(pheno.n) <- rownames(pheno)

        # EFF and pValue calculate
        res.p <- c()
        res.d <- c()


        for(pos in POS){

            # get alleles
            alleles <- hapData[,as.character(pos)]
            Als <- unique(alleles)
            Aln <- length(unique(Als))

            # get accessions of each genotype
            phenos <- list()
            for(i in seq_len(Aln)){
                probe <- c(alleles == Als[i])
                accs <- accessions[probe]
                phenos[[i]] <- pheno.n[accs]
            }
            # test start


            if(method == "auto"){
                if(is.quality) {
                    # quility pheno
                    res.ps <- chisq.test.ps(phenos)
                } else { # quantity pheno
                    # shaporo.test
                    sha.p <- sapply(phenos,
                                    function(x) {
                                        x <- na.omit(x)
                                        if(length(x) < 3) return(0)
                                        if(length(x) > 5000) x <- sample(x, 5000)
                                        shapiro.test(x)$p.value
                                    }
                    )
                    if(min(sha.p, na.rm = TRUE) >= 0.05){
                        # all sub data set fit normal distribution
                        res.ps <- t_test_for_ps(phenos)
                    } else {
                        # not all sub data set fit normal distribution
                        res.ps <- wilcox_test_for_ps(phenos)
                    }
                }
            } else {
                res.ps <- switch (method,
                                  "chisq.test" = chisq.test.ps(phenos),
                                  "t.test" = t_test_for_ps(phenos),
                                  "wilcox.test" = wilcox_test_for_ps(phenos)
                )
            }


            # test end
            p <- if(na.omit(res.ps$p) %>% length() > 0)
                min(res.ps$p, na.rm = TRUE) else NA
            d <- if(na.omit(res.ps$d) %>% length() > 0)
                max(res.ps$d, na.rm = TRUE) else NA
            res.p <- c(res.p, p)
            res.d <- c(res.d, d)

        }

        results.p <- rbind(results.p, res.p)
        results.d <- rbind(results.d, res.d)
    }

    if(p.adj != "none"){
        results.p <- matrix(p.adjust(as.matrix(results.p), method = p.adj),
                            nrow = nrow(results.p))
    }
    colnames(results.d) <- colnames(results.p) <- POS
    rownames(results.d) <- rownames(results.p) <- phenoNames
    # results <- cbind(pheno = phenoNames, results)
    # results.d$Chr <- results.p$Chr <- Chr
    # results.d$POS <- results.p$POS <- POS
    # results.d <- results.d[,c("Chr", "POS")]
    df <- data.frame(Chr = rep(Chr, length(POS)), POS = POS)
    results.p <- cbind(df, t(results.p))
    results.d <- cbind(df, t(results.d))
    return(list(p = results.p, EFF = results.d))
}


t_test_for_ps <- function(phenos){
    p <- c()
    d <- c()
    l = length(phenos)
    for(i in seq_len(l)){
        for(j in rev(seq_len(l))){
            if(i >= j) next
            phenoi <- phenos[[i]]
            phenoj <- phenos[[j]]

            # t.test or chisqure test or anova analysis
            pij.res <- try(t.test(phenoi, phenoj,
                                  alternative = "two.sided"),
                           silent = TRUE)
            if(inherits(pij.res, "htest")){
                pij <- pij.res$p.value
                dij <- abs(diff(pij.res$estimate))
            } else {
                pij <- NA
                dij <- NA
            }

            p <- c(p, pij)
            d <- c(d, dij)
        }
    }
    list(p = p, d = d)
}


chisq.test.ps <- function(phenos){
    nms <- phenos %>%
        unlist() %>%
        na.omit() %>%
        unique() %>%
        as.character()
    nms <- nms[order(nms)]
    l <- length(phenos)
    ptable <- matrix(ncol = length(nms),
                     nrow = l,
                     dimnames = list(seq_len(l),
                                     nms))
    for(i in seq_len(l)) {
        freqi <- table(phenos[[i]])
        ptable[i,] <- freqi[nms]
    }
    ptable[is.na(ptable)] <- 0
    p <- chisq.test(t(ptable))
    p <- p$p.value
    ptable.f <- matrix(nrow = nrow(ptable), ncol = ncol(ptable))
    for(i in seq_len(nrow(ptable)))
        ptable.f[i,] <- ptable[i,]/sum(ptable[i,])
    d <- 0
    for(i in seq_len(ncol(ptable)))
        d <- (max(ptable.f[,i], na.rm = TRUE) - min(ptable.f[,i], na.rm = TRUE)) / 2

    list(p = p, d = d)
}


wilcox_test_for_ps <- function(phenos){
    p <- c()
    d <- c()
    l = length(phenos)
    for(i in seq_len(l)){
        for(j in rev(seq_len(l))){
            if(i >= j) next
            phenoi <- phenos[[i]]
            phenoj <- phenos[[j]]

            # t.test or chisqure test or anova analysis
            pij.res <- try(wilcox.test(phenoi, phenoj,
                                       alternative = "two.sided",
                                       exact = FALSE),
                           silent = TRUE)
            if(inherits(pij.res, "htest")){
                pij <- pij.res$p.value
            } else {
                pij <- NA
            }
            p <- c(p, pij)
            dij <- c(mean(phenoi, na.rm = TRUE),
                     mean(phenoj, na.rm = TRUE)) %>%
                diff() %>% abs()
            d <- c(d, dij)
        }
    }
    list(p = p, d = d)

}




# add delta EFF plot function
#' @title plotEFF
#' @name plotEFF
#' @importFrom graphics par strwidth rect points
#' @importFrom grDevices colorRampPalette
#' @inherit siteEFF examples
#' @param siteEFF matrix, column name are pheno names and row name are site position
#' @param gff gff annotation
#' @param Chr the chromosome name
#' @param start start position
#' @param end end position
#' @param showType character vector, eg.: "CDS", "five_prime_UTR",
#' "three_prime_UTR"
#' @param CDS.height numeric indicate the height of CDS in gene model,
#' range: `[0,1]`
#' @param cex a numeric control the size of point
#' @param col vector specified the color bar
#' @param pch vector controls points type, see
#' \code{\link[graphics:par]{par()}}
#' @param main main title
#' @param legend.cex a numeric control the legend size
#' @param gene.legend whether add legend for gene model
#' @param markMutants whether mark mutants on gene model, default as `TRUE`
#' @param mutants.col color of lines which mark mutants
#' @param mutants.type a vector of line types
#' @param y,ylab,legendtitle *y:* indicate either pvalue or effect should be used as y axix,
#' **ylab,legendtitle:**,character, if missing, the value will be decide by y.
#' @param par.restore default as `TRUE`, wether restore the origin par after ploted EFF.
#' @return No return value, called for side effects
#' @export
plotEFF <- function(siteEFF, gff = gff,
                    Chr = Chr, start = start, end = end,
                    showType = c("five_prime_UTR", "CDS", "three_prime_UTR"),
                    CDS.height = CDS.height, cex = 0.1, col = c("red", "yellow"), pch = 20,
                    main = main, legend.cex = 0.8, gene.legend = TRUE,
                    markMutants = TRUE, mutants.col = 1, mutants.type = 1,
                    y = c("pvalue","effect"), ylab = ylab,
                    legendtitle = legendtitle,
                    par.restore = TRUE){
    # reset of par
    oldPar.fig <- par("fig")
    oldPar.mar.m <- oldPar.mar <- par("mar")
    oldPar.mar.m[4] <- 0
    oldPar.mar.m[1] <- 3

    if(par.restore)
        on.exit(par(fig = oldPar.fig, mar = oldPar.mar))

    Chr <- siteEFF$EFF[,1]
    POS <- as.numeric(siteEFF$EFF[,2])


    if(missing(start))
        start <- min(POS, na.rm = TRUE) - 0.05 * diff(range(POS))
    if(missing(end))
        end <- max(POS, na.rm = TRUE) + 0.05 * diff(range(POS))

    y <- y[1]
    if(y == "pvalue") {
        value_c <- as.matrix(siteEFF$EFF[,-c(1,2)])
        value_y <- -log10(siteEFF$p[,-c(1,2)]) %>% as.matrix()
        if(missing(ylab))
            ylab <- expression("-log"[10]~italic(p)~"Value")
        if(missing(legendtitle))
            legendtitle <- "effect"
    } else if(y == "effect") {
        value_c <- -log10(siteEFF$p[,-c(1,2)]) %>% as.matrix()
        value_y <- as.matrix(siteEFF$EFF[,-c(1,2)])
        if(missing(ylab))
            ylab <- "effect"
        if(missing(legendtitle))
            legendtitle <- expression("-log"[10]~italic(p)~"Value")
    } else {
        stop("y should be one of 'pvalue' or 'effect'")
    }

    # legend text and colors
    heatcols <- rev(grDevices::colorRampPalette(col)(1000))
    value_c.max <- max(value_c, na.rm = TRUE)
    value_c.min <- min(value_c, na.rm = TRUE)
    cols <- round((value_c - value_c.min + 1) / (value_c.max - value_c.min + 1) * 1000)
    cols <- matrix(heatcols[cols], ncol = ncol(cols))

    t1 <- value_c.max - (value_c.max - value_c.min) / 4 * 1
    t2 <- value_c.max - (value_c.max - value_c.min) / 4 * 2
    t3 <- value_c.max - (value_c.max - value_c.min) / 4 * 3


    # set of par
    par.mar <- oldPar.mar.m
    par.mar[3] <- 0
    par(fig = c(0, 0.78, 0, 1), mar = par.mar)


    # just plot
    plot(x = c(start, end), y = c(1, 1),
         yaxt = "n", type = "n", xlab="", ylab ="",
         frame.plot = FALSE)

    if(! missing(gff)){
        if(missing(Chr))
            stop("Chr is missing")

        # get GFF ranges for display
        gr <- GenomicRanges::GRanges(seqnames = Chr,
                                     ranges = IRanges::IRanges(start = start,
                                                               end = end))
        gff <- gff[IRanges::`%over%`(gff, gr)]
        gff <- gff[gff$type %in% showType]


        # plot genemodel
        # set of fig.h
        Parents <- unique(unlist(gff$Parent))
        nsplicement <- length(Parents)
        if(nsplicement == 0)
            stop("no sites on features defined by gff, please condsider adjust start and end")
        fig.h <- ifelse(nsplicement >= 5, 0.5, 0.1 * (1.2 + nsplicement))
        ln <- -0.6

        # SET OF PAR
        par.mar <- oldPar.mar.m
        par.mar[3] <- 0
        par(fig = c(0, 0.78, 0.01, fig.h + 0.01), mar = par.mar, new = TRUE)
        plot(start, xlim = c(start, end), ylim = c(0, nsplicement * 1.1),
             type = "n", xaxt = "n", yaxt = "n",
             xlab = "", ylab = "", frame.plot = FALSE)

        # markMutants
        if(markMutants){
            for(pos in POS){
                y.up <- ln + 1.1 * length(Parents) + 2.1
                lines(c(pos, pos), c(0.4, y.up),
                      col = mutants.col, lty = mutants.type)
            }
        }

        n <- 1
        Parents.txt <- c()
        Parents.y <- c()
        for(s in Parents){
            gffs <- gff[unlist(gff$Parent) == s]
            anno <- ifelse(gffs@strand[1] == "-", "3'<-5'", "5'->3'")

            ln <- ln + 1.1
            lines(c(start,end),c(ln,ln), col = "grey")
            text(start - strwidth(anno), ln, anno, xpd = TRUE)
            s.col <- rainbow(nsplicement)[n]
            n <- n + 1
            if(missing(CDS.height))
                CDS.height <- min(strheight(" ") * 1.5, 1)
            for(i in seq_len(length(gffs))){
                gffi <- gffs[i]
                h <- ifelse(gffi$type == "CDS", CDS.height, CDS.height * 0.5) * 0.5
                xl <- gffi@ranges@start
                xr <- xl + gffi@ranges@width - 1
                # rect(xleft = xl, xright = xr, ybottom = ln - h, ytop = ln + h, col = s.col)
                rect(xleft = xl, xright = xr, ybottom = ln - h, ytop = ln + h, col = "grey", lty = 0)
            }
            Parents.txt <- c(Parents.txt, s)
            Parents.y <- c(Parents.y, ln)
        }

        # add legend for gene model
        if(gene.legend){
            par.mar <- oldPar.mar.m
            par.mar[3] <- par.mar[2] <- par.mar[4] <- 0
            par(fig = c(0.78, 1, 0.01, fig.h + 0.01),
                mar = par.mar, new = TRUE)
            plot(start, xlim = c(0,1), ylim = c(0, nsplicement * 1.1),
                 type = "n", xaxt = "n", yaxt = "n",
                 xlab = "", ylab = "", frame.plot = FALSE)
            for(i in seq_len(length(Parents.y))){
                text(0, Parents.y[i], Parents.txt[i],
                     xpd = TRUE, adj = 0, cex = legend.cex)
            }
        }

        # add shape legend
        if(length(unique(pch)) != 1){
            if(length(pch) != ncol(value_y))
                stop("length of 'pch' (", length(pch),
                     ") not equal with numner of phenos (",
                     ncol(value_y), ")")
            par.mar <- oldPar.mar
            par.mar[1] <- 0
            par.mar[2] <- 0.5
            par.mar[3] <- 0.5

            par(mar = par.mar, fig = c(0.78, 0.98, fig.h, 0.4 + fig.h * 0.4),
                new = TRUE)
            plot(y = 1,
                 x = 1,
                 xlim = c(0, 1),
                 ylim = c(0, 1),
                 xlab = "", ylab = "",
                 xaxt = 'n',
                 yaxt = 'n',
                 type = "n",
                 frame.plot  = FALSE)
            nms <- colnames(value_y)
            hspace <- strwidth(" ", cex = legend.cex)
            SHIFT <- strheight(" ", cex = legend.cex) * 1.25
            for(i in seq_len(length(pch))){
                points(x = hspace,
                       y = 1 - SHIFT * i,
                       cex = legend.cex, pch = pch[i])

                text(3 * hspace, 1 - SHIFT * i, nms[i],
                     xpd = TRUE, adj = 0, cex = legend.cex)
            }
        }


        # add color legend
        # set of mar
        par.mar <- oldPar.mar
        par.mar[1] <- 0.5
        par.mar[2] <- 1.5
        par(mar = par.mar, fig = c(0.78, 0.98, 0.4 + fig.h * 0.4, 1), new = TRUE)
        plot(y = 12,
             x = 1,
             xlim = c(0, 1),
             ylim = c(0, 1000),
             xlab = "", ylab = "",
             xaxt = 'n',
             yaxt = 'n',
             type = 'n',
             frame.plot  = FALSE)
        rect(xleft = rep(0, 1000),
             ybottom = seq_len(1000),
             xright = rep(4 * strwidth(" "), 1000),
             ytop = seq_len(1000) + 1,
             col = heatcols,
             border = NA)
        xy <- par("usr")
        text(6 * strwidth(" "), 1000, round(value_c.max, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 750, round(t1, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 500, round(t2, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 250, round(t3, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 0, round(value_c.min, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(xy[1] - strwidth(" "), 1000, legendtitle,
             xpd = TRUE, cex = legend.cex, adj = c(1, 0), srt = 90)



        # plot EFFs
        # set of mar
        par.mar <- oldPar.mar.m
        par.mar[1] <- 0

        # set of par and plot frame
        par(fig = c(0, 0.78, fig.h + 0.01, 1), mar = par.mar, new = TRUE)
        plot(x = POS[1], y = value_y[1, 1], type = "n",
             xlim = c(start, end), ylim = c(0, max(value_y, na.rm = TRUE)),
             col = 3, cex = 0.5,
             xaxt = "n", xlab = "", ylab = ylab)

        if(missing(col)) col <- seq_len(nrow(value_y)) else
            col <- if(length(col) == 1) rep(col, nrow(value_y)) else col

        if(missing(pch)) pch <- 20
        pch <- if(length(pch) != nrow(value_y)) rep(pch, nrow(value_y)) else pch


        # plot points indicate EFFs
        # TODO
        # 1. add color for pValue
        # 2. height for EFF
        for(i in seq_len(ncol(value_y))){
            points(x = POS,
                   y = value_y[,i],
                   cex = 1, col = cols[,i], pch = pch[i])
        }

        # add title
        if(!missing(main))
            title(main = main)



    } else {
        # add shape legend
        if(length(unique(pch)) != 1){
            if(length(pch) != ncol(value_y))
                stop("length of 'pch' (", length(pch),
                     ") not equal with numner of phenos (",
                     ncol(value_y), ")")
            par.mar <- oldPar.mar
            par.mar[1] <- 0
            par.mar[2] <- 0.5
            par.mar[3] <- 0.5

            par(mar = par.mar, fig = c(0.78, 0.98, 0.1, 0.4),
                new = TRUE)
            plot(y = 1,
                 x = 1,
                 xlim = c(0, 1),
                 ylim = c(0, 1),
                 xlab = "", ylab = "",
                 xaxt = 'n',
                 yaxt = 'n',
                 type = "n",
                 frame.plot  = FALSE)
            nms <- colnames(value_y)
            hspace <- strwidth(" ", cex = legend.cex)
            SHIFT <- strheight(" ", cex = legend.cex) * 1.25
            for(i in seq_len(length(pch))){
                points(x = hspace,
                       y = 1 - SHIFT * i,
                       cex = legend.cex, pch = pch[i])

                text(3 * hspace, 1 - SHIFT * i, nms[i],
                     xpd = TRUE, adj = 0, cex = legend.cex)
            }
        }


        # add color legend
        # set of mar
        par.mar <- oldPar.mar
        par.mar[1] <- 0.5
        par.mar[2] <- 1.5
        par(mar = par.mar, fig = c(0.78, 0.98, 0.4, 1), new = TRUE)
        plot(y = 1,
             x = 1,
             xlim = c(0, 1),
             ylim = c(0, 1000),
             xlab = "", ylab = "",
             xaxt = 'n',
             yaxt = 'n',
             type = 'n',
             frame.plot  = FALSE)
        rect(xleft = rep(0, 1000),
             ybottom = seq_len(1000),
             xright = rep(4 * strwidth(" "), 1000),
             ytop = seq_len(1000) + 1,
             col = heatcols,
             border = NA)
        xy <- par("usr")
        text(6 * strwidth(" "), 1000, round(value_c.max, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 750, round(t1, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 500, round(t2, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 250, round(t3, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(6 * strwidth(" "), 0, round(value_c.min, 2), xpd = TRUE, adj = 0, cex = legend.cex)
        text(xy[1] - strwidth(" "), 1000, legendtitle,
             xpd = TRUE, cex = legend.cex, adj = c(1, 0), srt = 90)


        # plot EFFs
        # set of mar
        par.mar <- oldPar.mar.m
        # set of par and plot frame
        par(fig = c(0, 0.78, 0, 1), mar = par.mar, new = TRUE)
        plot(x = POS[1], y = value_y[1,1], type = "n",
             xlim = c(start, end), ylim = c(0, max(value_y, na.rm = TRUE)),
             col = 3, cex = 0.5,
             xlab = "", ylab = ylab)

        if(missing(col)) col <- seq_len(nrow(value_y)) else
            col <- if(length(col) == 1) rep(col, nrow(value_y)) else col

        if(missing(pch)) pch <- 20
        pch <- if(length(pch) != nrow(value_y)) rep(pch, nrow(value_y)) else pch


        # plot points indicate EFFs
        # TODO
        # 1. add color for pValue
        # 2. height for EFF
        for(i in seq_len(ncol(value_y))){
            points(x = POS,
                   y = value_y[, i],
                   cex = 1, col = cols[, i], pch = pch[i])
        }

        # add title
        if(!missing(main))
            title(main = main)



    }
}



# phenos scale function here
pscale <- function(x){
    # remove outlier
    x <- removeOutlier(x)
    # scale
    x.max <- max(x, na.rm = TRUE)
    x.min <- min(x, na.rm = TRUE)
    x <- (x - x.min)/(x.max - x.min)
    return(100 * x)
}


# comparison of all sites
#' @title sites comparison
#' @name sites_compar
#' @description Used for all allele effect compare once
#' @param hap object of hapResult class
#' @param pheno a data.frame contains phenotypes
#' @param phenoName the name of used phenotype
#' @param hetero_remove removing the heter-sites or not, default as TRUE
#' @param title the title of the figure
#' @param file if provieds a file path the comparing results will saved to file.
# @export
compareAllSites <- function(hap, pheno, phenoName = names(pheno)[1],
                            hetero_remove = TRUE, title = "", file = file){
    if(! inherits(hap, "hapReult"))
        stop("The haplotype result is provied in wrong format")
    if(! inherits(pheno, "data.frame"))
        warning("phenotype format warnning")
    if(! missing(file))
        if(file.exists(file))
            warning("'", file,"' is already exist, it will be overwrited")

}
