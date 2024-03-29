#' @name hapVsPheno
#' @title hapVsPheno
#' @examples
#'
#' \donttest{
#' data("geneHapR_test")
#' # plot the figs directly
#' hapVsPheno(hap = hapResult,
#'            pheno = pheno,
#'            phenoName = "GrainWeight.2021",
#'            minAcc = 3)
#'
#' # do not merge the files
#' results <- hapVsPheno(hap = hapResult,
#'                       pheno = pheno,
#'                       phenoName = "GrainWeight.2021",
#'                       minAcc = 3,
#'                       mergeFigs = FALSE)
#' plot(results$fig_pvalue)
#' plot(results$fig_Violin)
#' }
#' @param hap object of hapResult class, generate with`vcf2hap()` or
#' `seqs2hap()`
#' @param pheno object of data.frame class, imported by `import_pheno()`
#' @param phenoName pheno name for plot, should be one column name of pheno
#' @param hapPrefix prefix of hapotypes, default as "H"
#' @param title a charater which will used for figure title
#' @param mergeFigs bool type, indicate whether merge the heat map and box
#' plot or not. Default as `FALSE`
#' @param minAcc,freq.min If observations number of a Hap less than this number will
#' not be compared with others or be ploted. Should not less than 3 due to the
#' t-test will meaninglessly. Default as 5
#' @param outlier.rm whether remove ouliers, default as TRUE
#' @param angle the angle of x labels
#' @param hjust,vjust hjust and vjust of x labels
#' @param comparisons a list contains comparison pairs
#' eg. `list(c("H001", "H002"), c("H001", "H004"))`,
#' or a character vector contains haplotype names for comparison,
#' or "none" indicates do not add comparisons.
# @param method a character string indicating which method to be used for comparing means.
# @param ... options will pass to `ggpubr`
#' @inheritDotParams ggpubr::ggviolin
#' @inheritParams ggpubr::stat_compare_means
#' @importFrom stats na.omit t.test
#' @importFrom rlang .data
#' @return list. A list contains a character vector with Haps were applied
#' student test, a mattrix contains p-value of each compare of Haps and a
#' ggplot2 object named as figs if mergeFigs set as `TRUE`, or two ggplot2
#' objects names as fig_pvalue and fig_Violin
#' @export
hapVsPheno <- function(hap,
                       pheno,
                       phenoName,
                       hapPrefix = "H",
                       title = "",
                       comparisons = comparisons,
                       method = "t.test",
                       method.args = list(),
                       symnum.args = list(),
                       mergeFigs = FALSE,
                       angle = angle,
                       hjust = hjust,
                       vjust = vjust,
                       minAcc = minAcc,
                       freq.min = freq.min,
                       outlier.rm = TRUE,
                       ...)
{
    if(! inherits(hap, "hapResult"))
        stop("hap should be object of 'hapResult' class")
    if (missing(phenoName)) {
        warning("phenoName is null, will use the first pheno")
        phenoName <- colnames(pheno)[1]
    }
    if (!(phenoName %in% colnames(pheno))) {
        stop("Could not find ", phenoName, " in colnames of pheno")
    }

    result <- list()
    hap <- hap[stringr::str_starts(hap[, 1], hapPrefix),]
    Accessions <- hap[, colnames(hap) == "Accession"]
    haps <- hap[, 1]
    names(haps) <- Accessions

    pheno$Hap <- haps[row.names(pheno)]
    phenop <- pheno[, c("Hap", phenoName)]
    names(phenop)[2] <- "Cur_p"
    # remove outliers
    if(outlier.rm)
        phenop[, "Cur_p"] <- removeOutlier(phenop[, "Cur_p"])

    phenop <- na.omit(phenop)
    if (nrow(phenop) == 0)
        stop(
            "After removed NAs, observations for '",
            phenoName,
            "' is not enough."
        )

    hps <- table(phenop$Hap)
    if(missing(minAcc)){
        if(missing(freq.min)) minAcc <- 5 else minAcc <- freq.min
    }
    # filter Haps for plot
    if (max(hps) < minAcc)
        stop("there is no haps to plot (no Haps with observations more than ",
             minAcc,
             ")")

    hps <- hps[hps >= minAcc]

    hpsnm <- names(hps)
    hps <- paste0(names(hps), "(", hps, ")")
    names(hps) <- hpsnm

    # T test
    plotHap <- c()
    my_comparisons <- list()
    T.Result <- matrix(nrow = length(hpsnm), ncol = length(hpsnm))
    colnames(T.Result) <- hpsnm
    row.names(T.Result) <- hpsnm
    nr = nrow(T.Result)

    for (m in seq_len(nr)) {
        for (n in nr:m) {
            i <- hpsnm[m]
            j <- hpsnm[n]
            hapi <- phenop[phenop$Hap == i, "Cur_p"]
            hapj <- phenop[phenop$Hap == j, "Cur_p"]
            if (length(hapi) >= minAcc & length(hapj) >= minAcc) {
                pvalue <- try(t.test(hapi, hapj)$p.value, silent = TRUE)

                T.Result[j, i] <- ifelse(is.numeric(pvalue) &
                                             !is.na(pvalue),
                                         pvalue, 1)
                T.Result[i, j] <- T.Result[j, i]
                plotHap <- c(plotHap, i, j)
                if (T.Result[i, j] < 0.05) {
                    my_comparisons <- c(my_comparisons,
                                        list(hps[c(i, j)]))
                }
            }
        }
    }

    result$plotHap <- unique(plotHap)
    result$T.Result <- T.Result
    plotHap <- unique(plotHap)
    if (is.null(plotHap))
        stop("there is no haps to plot (no Haps with observations more than ",
             minAcc)

    if (length(plotHap) > 1) {
        T.Result <- T.Result[!is.na(T.Result[, 1]), !is.na(T.Result[1, ])]

        # ggplot

        if (nrow(T.Result) > 1)  {
            # get upper or lower tri
            T.Result[lower.tri(T.Result)] = NA
        }
        melResult <- reshape2::melt(T.Result, na.rm = TRUE)

        melResult$label <- ifelse(melResult$value > 1,
                                  1,
                                  ifelse(
                                      melResult$value < 0.001,
                                      0.001,
                                      round(melResult$value, 3)
                                  ))

        fig1 <- ggplot2::ggplot(data = melResult,
                                mapping = ggplot2::aes_(
                                    x =  ~ Var1,
                                    y =  ~ Var2,
                                    fill =  ~ value
                                )) +
            ggplot2::geom_tile(color = "white") +
            ggplot2::ggtitle(label = title, subtitle = phenoName) +
            ggplot2::scale_fill_gradientn(
                colours = c("red", "grey", "grey90"),
                limit = c(0, 1.000001),
                name = parse(text = "italic(p)~value")
            ) +
            ggplot2::geom_text(
                ggplot2::aes_(
                    x =  ~ Var1,
                    y =  ~ Var2,
                    label =  ~ label
                ),
                color = "black",
                size = 4
            ) +
            ggplot2::theme(
                axis.title.x =  ggplot2::element_blank(),
                axis.title.y =  ggplot2::element_blank(),
                panel.grid.major =  ggplot2::element_blank(),
                panel.border =  ggplot2::element_blank(),
                panel.background =  ggplot2::element_blank(),
                axis.ticks =  ggplot2::element_blank(),
                plot.subtitle = ggplot2::element_text(hjust = 0.5),
                plot.title = ggplot2::element_text(hjust = 0.5)
            ) +
            ggplot2::guides(fill = ggplot2::guide_colorbar(title.position = "top",
                                                           title.hjust = 0.5))
    } else
        fig1 <- ggplot2::ggplot() + ggplot2::theme_minimal()

    # boxplot
    data <- phenop[phenop$Hap %in% plotHap,]
    data <- data[order(data$Hap, decreasing = FALSE),]

    data$Hap <- hps[data$Hap]
    capt <- stringr::str_split(phenoName, "[.]")[[1]][2]
    if (is.na(capt))
        fig2 <- ggpubr::ggviolin(
            data,
            x = "Hap",
            y = "Cur_p",
            color = "Hap",
            legend = "right",
            legend.title = "",
            add = "boxplot",
            ...
        )
    else
        fig2 <- ggpubr::ggviolin(
            data,
            x = "Hap",
            y = "Cur_p",
            color = "Hap",
            caption = capt,
            legend = "right",
            legend.title = "",
            add = "boxplot",
            ...
        )

    if(missing(angle))
        angle <- ifelse(length(hps) >= 6, 45, 0)
    if(angle > 0 & angle < 90)
    {
        if(missing(hjust)) hjust = 1
        if(missing(vjust)) vjust = 1
    }
    if(angle < 0 & angle > -90)
    {
        if(missing(hjust)) hjust = 0.1
        if(missing(vjust)) vjust = 0.1
    }
    if(angle == 0)
    {
        if(missing(hjust)) hjust = 0.5
        if(missing(vjust)) vjust = 0.5
    }
    fig2 <- fig2 +  # do not modify here
        #    stat_compare_means(label.y = max(data[,2]))+
        #    no comparision by remove this line (Kruskal-Wallis test)
        ggplot2::ggtitle(label = title) +
        ggplot2::theme(
            plot.subtitle = ggplot2::element_text(hjust = 0.5),
            axis.text.x = ggplot2::element_text(
                angle = angle,
                hjust = hjust,
                vjust = vjust
            ),
            plot.title = ggplot2::element_text(hjust = 0.5)
        ) +
        ggplot2::ylab(stringr::str_split(phenoName, "[.]")[[1]][1])

    if(! missing(comparisons)){
        if(inherits(comparisons, "list")) {
            for(i in seq_len(length(comparisons)))
                comparisons[[i]] <- hps[comparisons[[i]]]
            my_comparisons <- comparisons
        } else if(inherits(comparisons, "character")){
            if(comparisons[1] == "none") {
                my_comparisons <- list()
            } else {
                comparisons <- hps[comparisons]
                probe <- c()
                for(i in my_comparisons)
                    probe <- c(probe, TRUE %in% (i %in% comparisons))
                my_comparisons <- my_comparisons[probe]
            }
        }
    }

    if (length(my_comparisons) > 0) {
        fig2 <- fig2 + # 添加箱线图
            ggpubr::stat_compare_means(
                comparisons = unique(my_comparisons),
                paired = FALSE,
                method.args = method.args,
                symnum.args = symnum.args,
                method = method
            )
    }

    if (mergeFigs)  {
        fig3 <- ggpubr::ggarrange(fig1,
                                  fig2,
                                  nrow = 1,
                                  labels = c("A", "B"))
        result$figs <- fig3
    } else {
        result$fig_pvalue <- fig1
        result$fig_Violin <- fig2
    }

    return(result)
}



#' @name hapVsPhenos
#' @title hapVsPhenos
#' @param outPutSingleFile `TRUE` or `FALSE` indicate whether put all figs
#' into to each pages of single file or generate multi-files.
#' Only worked while file type is pdf
#' @param width manual option for determining the output file width in inches.
#' (default: 12)
#' @param height manual option for determining the output file height in inches.
#' (default: 8)
#' @param res The nominal resolution in ppi which will be recorded in the
#' bitmap file, if a positive integer. Also used for units other than the
#' default, and to convert points to pixels
#' @inheritParams grDevices::tiff
#' @param filename.prefix,filename.surfix,filename.sep
#' if multi files generated, file names will be formed by
#' prefix `filename.prefix`, a seperate charcter `filename.sep`,
#' pheno name, a dot and surfix `filename.surfix`,
#' and file type was decide by `filename.surfix`;
#' if single file was generated, file name will be formed by
#' prefix `filename.prefix`, a dot and surfix `filename.surfix`
#' @inheritParams hapVsPheno
#' @inheritDotParams hapVsPheno
#' @examples
#' \donttest{
#' data("geneHapR_test")
#'
#' oriDir <- getwd()
#' temp_dir <- tempdir()
#' if(! dir.exists(temp_dir))
#'   dir.create(temp_dir)
#' setwd(temp_dir)
#' # analysis all pheno in the data.frame of pheno
#' hapVsPhenos(hapResult,
#'             pheno,
#'             outPutSingleFile = TRUE,
#'             hapPrefix = "H",
#'             title = "Seita.0G000000",
#'             filename.prefix = "test",
#'             width = 12,
#'             height = 8,
#'             res = 300)
#' setwd(oriDir)
#' }
#' @importFrom stats na.omit t.test
#' @import grDevices
#' @export
#' @return No return value
hapVsPhenos <- function(hap,
                        pheno,
                        outPutSingleFile = TRUE,
                        hapPrefix = "H",
                        title = "Seita.0G000000",
                        width = 12,
                        height = 8,
                        res = 300,
                        compression = "lzw",
                        filename.prefix = filename.prefix,
                        filename.surfix = "pdf",
                        filename.sep = "_",
                        outlier.rm = TRUE,
                        mergeFigs = TRUE,
                        ...) {

    # pheno association
    if (missing(hap))
        stop("hap is missing!")

    if (missing(pheno))
        stop("pheno is missing!")

    if(missing(filename.prefix))
        stop("filename.prefix is missing!")

    if (!filename.surfix %in% c("pdf", "png", "tif", "tiff", "jpg", "jpeg", "bmp"))
        stop("The file type should be one of pdf, png, tiff, jpg and bmp")

    if (filename.surfix != "pdf")
        outPutSingleFile <- FALSE

    probe <- ifelse(filename.surfix == "pdf",
                    ifelse(outPutSingleFile,
                           TRUE,
                           FALSE),
                    FALSE)
    if (probe) {
        filename <- paste0(filename.prefix,".",filename.surfix)
        message("
        File type is pdf and 'outPutSingleFile' set as TRUE,
        all figs will plot in ",
                filename)
        pdf(filename, width = width, height = height)
        on.exit(dev.off())
    }
    if (!is.data.frame(pheno))
        stop("pheno should be a data.frame object")
    if (ncol(pheno) == 1)
        warning("There is only one col detected in pheno, 'hapVsPheno' is prefered")
    phenoNames <- colnames(pheno)
    steps <- 0
    for (phenoName in phenoNames) {
        if (!probe) {
            filename <- paste0(filename.prefix,
                               filename.sep,
                               phenoName,
                               ".",
                               filename.surfix)
            switch(
                filename.surfix,
                "pdf" = pdf(filename, width = width, height = height),
                "png" = png(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res
                ),
                "bmp" = bmp(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res
                ),
                "jpg" = png(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res
                ),
                "jpeg" = png(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res
                ),
                "tif" = tiff(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res,
                    compression = compression
                ),
                "tiff" = tiff(
                    filename = filename,
                    width = width,
                    height = height,
                    units = "in",
                    res = res,
                    compression = compression
                )
            )
        }
        steps <- steps + 1
        message("Total: ",
                ncol(pheno),
                "; current: ",
                steps,
                ";\tphynotype: ",
                phenoName, appendLF = FALSE)
        cat("\tfile: ", filename, "\n", sep = "")

        resulti <- try(hapVsPheno(hap = hap,
                                  pheno = pheno,
                                  phenoName = phenoName,
                                  hapPrefix = hapPrefix,
                                  title = title,
                                  mergeFigs = mergeFigs,
                                  ...))
        if(!inherits(resulti, "try-error")) {
            if(mergeFigs) plot(resulti$figs) else plot(resulti$fig_Violin)
        }else resulti
        if (!probe)
            dev.off()
        resulti <- NULL
    }
}


# getSurFix <- function(Name) {
#     parts <- strsplit(Name, ".", fixed = TRUE,)
#     lparth <- length(parts[[1]])
#     surFix <- parts[[1]][lparth]
#     surFix <- stringr::str_to_lower(surFix)
#     return(surFix)
# }


#' @title hapVsPhenoPerSite
#' @description Comparie phenotype site by site.
#' @param hap an R object of hapresult class
#' @param pheno,phenoName pheno, a data.frame contains the phenotypes;
#' Only one phenotype name is required.
#' @param sitePOS the coordinate of site
#' @param fileName,fileType file name and file type will be needed for saving result,
#' file type could be one of "png, tiff, jpg"
#' @param freq.min miner allies frequency less than freq.min will not be skipped
#' @param ... addtional params will be passed to plot saving function like `tiff()`, `png()`, `pdf()`
#' @importFrom utils askYesNo
#' @examples
#' data("geneHapR_test")
#' hapVsPhenoPerSite(hapResult, pheno, sitePOS = "4300")
#' @export
hapVsPhenoPerSite <- function(hap, pheno, phenoName, sitePOS,
                              fileName, fileType = NULL, freq.min = 5, ...){
    if(! inherits(hap, "hapResult"))
        stop("hap should be object of 'hapResult' class")
    if(missing(hap) | missing(pheno))
        stop("missing parameters, please check your input")
    ids <- row.names(pheno)
    if(missing(phenoName)){
        message("phenoName is missing, the first phenotype in pheno will be used")
        phenoName <- names(pheno)[1]
    }
    if(is.vector(pheno))
        if(is.null(names(pheno)))
            stop("Required a named vector!") else {
                nmsp <- names(pheno)
                pheno <- data.frame(pheno = pheno)
                row.names(pheno) <- nmsp
                phenoName <- "pheno"
            }
    pheno <- pheno[, phenoName]

    names(pheno) <- ids

    if(! is.null(fileType))
        if(missing(fileName))
            stop("File name is missing!!!")
    pos <- suppressWarnings(as.numeric(names(hap)))
    if(missing(sitePOS)){
        i <- 1
        while (TRUE) {
            if(i > ncol(hap)) break
            if(is.na(pos[i])){
                i <- i + 1
                next
            }
            hapi <- hap[-c(1:4),c(i, ncol(hap))]
            p <- suppressWarnings(plotHapi(hapi, pheno, freq.min, phenoName))

            # save result
            if(is.null(p)) {
                i <- i + 1
                next
            } else {
                if(! is.null(fileType)){
                    f <- get(tolower(fileType))
                    fileName <- paste0(fileName, "_", pos[i], ".", fileType)
                    f(fileName, ...)
                    suppressWarnings(plot(p))
                    dev.off()
                }

                suppressWarnings(plot(p))
            }
            # break or continue
            l = readline("proceed? 'Y' for yes, 'N' for no")
            if(l != "" & l != "Y") break
            i <- i + 1
        }
    } else {
        if(as.character(sitePOS) %in% names(hap))
            k <- which(names(hap) == as.character(sitePOS)) else
                stop("Wrong site postion not found in haps")
        hapi <- hap[-c(1:4),c(k, ncol(hap))]
        p <- suppressWarnings(plotHapi(hapi, pheno, freq.min, phenoName))

        # save result
        if(! is.null(p)) {
            if(! is.null(fileType)){
                f <- get(tolower(fileType))
                fileName <- paste0(fileName, "_", pos[i], ".", fileType)
                f(fileName, ...)
                suppressWarnings(plot(p))
                dev.off()
            }

            suppressWarnings(plot(p))
        }

    }
}



plotHapi <- function(hapi, pheno, freq.min, phenoName, method = "t.test"){
    # pheno: a named vector
    hapi$pheno <- pheno[hapi$Accession]
    pos <- names(hapi)[1]
    hapi <- data.frame(hapi)
    hapi <- na.omit(hapi)
    c <- 0 # count for acc numbers
    als <- unique(hapi[,1])
    ph <- c(paste0("pheno_", als))
    names(ph) <- als
    for(i in als){
        tmp <- data.frame(hapi)
        tmp <- hapi[hapi[,1] == i, "pheno"]
        tmp <- na.omit(tmp)
        if(length(tmp) >= freq.min) c <- c + 1
        assign(ph[i], tmp)
    }
    if(c < 2) return(NULL)

    compares <- list()
    for(i in seq_len(length(als)))
        for (j in i:length(als)){
            if (i != j) {
                compares <- c(compares, list(c(als[i], als[j])))
            }
        }

    hapi <- as.data.frame(hapi)
    names(hapi) <- c("Allele","Accession","Pheno")

    fig2 <- ggpubr::ggviolin(
        hapi,
        "Allele",
        "Pheno",
        color = "Allele",
        legend = "right",
        legend.title = "",
        xlab = paste("position:",pos),
        ylab = phenoName,
        add = "boxplot")
    fig2 + ggpubr::stat_compare_means(
        comparisons = unique(compares),
        method = method
    )
}


# # 卡方检验数量性状（等级）
# library(stringr)
# library(magrittr)
#
# pheno = pheno[,str_detect(names(pheno),"tude")]
# names(pheno)
# freq.min = 5
# ptest = pheno[,1]
# names(ptest) = row.names(pheno)
# acc2hap <- attr(hap,"hap2acc")
# haps <- unique(hap$Hap[-c(1:4)])
# ps <- matrix(nrow = length(haps), ncol = length(haps))
# colnames(ps) <- rownames(ps) <- haps
# plotHap <- c()
# for(h1 in haps){
#     for(h2 in haps){
#         if(h1 == h2) ps[h1,h2] <- 1 else{
#             phe1 <- ptest[acc2hap[names(acc2hap) == h1]] %>% na.omit()
#             phe2 <- ptest[acc2hap[names(acc2hap) == h2]] %>% na.omit()
#             if(length(phe1) > freq.min & length(phe2) > freq.min){
#                 plotHap <- c(plotHap,h1,h2)
#                 nms <- names(table(c(phe1,phe2)))
#                 phe <- rbind(table(phe1)[nms],
#                              table(phe2)[nms])
#                 phe[is.na(phe)] <- 0
#                 rownames(phe) = c(h1,h2)
#                 res <- chisq.test(phe)
#                 ps[h1,h2] = res$p.value
#             }
#         }
#     }
# }
# plotHap <- unique(plotHap)
# ps<- ps[plotHap,plotHap]
# heatmap(ps)
#
#
#
#
# nms <- names(table(ptest))
# res <- data.frame()
# for(h1 in haps){
#     resh <- ptest[acc2hap[names(acc2hap) == h1]] %>% na.omit()
#     if(length(resh) > freq.min){
#         t <- table(resh)[nms]
#         res <- rbind(res, t)
#         row.names(res)[nrow(res)] <- h1
#     }
# }
# names(res) <- nms
# res[is.na(res)] <- 0
# res$Hap <- row.names(res)
# res <- reshape2::melt(res, id = "Hap")
# library(reshape2)
# p <- ggplot(data = res, mapping = aes(x = Hap, fill = variable, y = value))
# p + geom_bar(stat = "identity", position = "fill")
# table(res$Hap)
# head(res)
# p = ggpubr::ggbarplot(res, "Hap", "value",fill = "variable",position = position_fill(),
#                       legend = "right")
# topptx(p, file = "p.pptx", width = 8, height = 6)
# topptx(p, file = "p.pptx", width = 4, height = 3, append = T)
# hapVsPheno
# attr(hap,"freq")
# dev.off()
# res
# ps %>% data.frame() %>% na.omit()# %>% t() %>% na.omit()
# a.omit(ps)
