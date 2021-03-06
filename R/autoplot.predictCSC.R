### autoplot.predictCSC.R --- 
#----------------------------------------------------------------------
## author: Brice Ozenne
## created: feb 27 2017 (10:47) 
## Version: 
## last-updated: sep 24 2020 (14:30) 
##           By: Brice Ozenne
##     Update #: 103
#----------------------------------------------------------------------
## 
### Commentary: 
## 
### Change Log:
#----------------------------------------------------------------------
## 
### Code:

## * autoplot.predictCSC (documentation)
#' @title Plot Predictions From a Cause-specific Cox Proportional Hazard Regression
#' @description Plot predictions from a Cause-specific Cox proportional hazard regression.
#' @name autoplot.predictCSC
#' 
#' @param object Object obtained with the function \code{predictCox}.
#' @param ci [logical] If \code{TRUE} display the confidence intervals for the predictions.
#' @param band [logical] If \code{TRUE} display the confidence bands for the predictions.
#' @param group.by [character] The grouping factor used to color the prediction curves. Can be \code{"row"}, \code{"strata"}, or \code{"covariates"}. 
#' @param reduce.data [logical] If \code{TRUE} only the covariates that does take indentical values for all observations are displayed.
#' @param plot [logical] Should the graphic be plotted.
#' @param digits [integer] Number of decimal places.
#' @param smooth [logical] Should a smooth version of the risk function be plotted instead of a simple function?
#' @param alpha [numeric, 0-1] Transparency of the confidence bands. Argument passed to \code{ggplot2::geom_ribbon}.
#' @param ... Additional parameters to cutomize the display.
#' 
#' @return Invisible. A list containing:
#' \itemize{
#' \item plot: the ggplot object.
#' \item data: the data used to create the plot.
#' }
#'
#' @seealso
#' \code{\link{predict.CauseSpecificCox}} to compute risks based on a CSC model.

## * autoplot.predictCSC (examples)
#' @examples
#' library(survival)
#' library(rms)
#' library(ggplot2)
#' library(prodlim)
#' 
#' #### simulate data ####
#' set.seed(10)
#' d <- sampleData(1e2, outcome = "competing.risks")
#' seqTau <- c(0,unique(sort(d[d$event==1,time])), max(d$time))
#' 
#' #### CSC model ####
#' m.CSC <- CSC(Hist(time,event)~ X1 + X2 + X6, data = d)
#' 
#' pred.CSC <- predict(m.CSC, newdata = d[1:2,], time = seqTau, cause = 1, band = TRUE)
#' autoplot(pred.CSC, alpha = 0.2)
#' 
#' #### stratified CSC model ####
#' m.SCSC <- CSC(Hist(time,event)~ strata(X1) + strata(X2) + X6,
#'               data = d)
#' pred.SCSC <- predict(m.SCSC, time = seqTau, newdata = d[1:4,],
#'                      cause = 1, keep.newdata = TRUE, keep.strata = TRUE)
#' autoplot(pred.SCSC, group.by = "strata")

## * autoplot.predictCSC (code)
#' @rdname autoplot.predictCSC
#' @method autoplot predictCSC
#' @export
autoplot.predictCSC <- function(object,
                                ci = object$se,
                                band = object$band,
                                plot = TRUE,
                                smooth = FALSE,
                                digits = 2,
                                alpha = NA,
                                group.by = "row",
                                reduce.data = FALSE,
                                ...){
  
    ## initialize and check
    group.by <- match.arg(group.by, c("row","covariates","strata"))
  
    if(group.by[[1]] == "covariates" && ("newdata" %in% names(object) == FALSE)){
        stop("argument \'group.by\' cannot be \"covariates\" when newdata is missing in the object \n",
             "set argment \'keep.newdata\' to TRUE when calling the predictCox function \n")
    }
    if(group.by[[1]] == "strata" && ("strata" %in% names(object) == FALSE)){
        stop("argument \'group.by\' cannot be \"strata\" when strata is missing in the object \n",
             "set argment \'keep.strata\' to TRUE when calling the predictCox function \n")
    }
  
    if(ci[[1]] && (object$se[[1]]==FALSE || is.null(object$conf.level))){
        stop("argument \'ci\' cannot be TRUE when no standard error have been computed \n",
             "set arguments \'se\' and \'confint\' to TRUE when calling the predict.CauseSpecificCox function \n")
    }
    if(band[[1]] && (object$band[[1]]==FALSE  || is.null(object$conf.level))){
        stop("argument \'band\' cannot be TRUE when the quantiles for the confidence bands have not been computed \n",
             "set arguments \'band\' and \'confint\' to TRUE when calling the predict.CauseSpecificCox function \n")
    }
    if(any(rank(object$times) != 1:length(object$times))){
        stop("Invalid object. The prediction times must be strictly increasing \n")
    }
    
    ## dots <- list(...)
    ## if(length(dots)>0){
    ##     txt <- names(dots)
    ##     txt.s <- if(length(txt)>1){"s"}else{""}
    ##     stop("unknown argument",txt.s,": \"",paste0(txt,collapse="\" \""),"\" \n")
    ## }
    

    ## display
    newdata <- copy(object$newdata)
    if(!is.null(newdata) && reduce.data[[1]]){
        test <- unlist(newdata[,lapply(.SD, function(col){length(unique(col))==1})])
        if(any(test)){
            newdata[, (names(test)[test]):=NULL]
        }        
    }

    dataL <- predict2melt(outcome = object$absRisk, ci = ci, band = band, 
                          outcome.lower = if(ci){object$absRisk.lower}else{NULL},
                          outcome.upper = if(ci){object$absRisk.upper}else{NULL},
                          outcome.lowerBand = if(band){object$absRisk.lowerBand}else{NULL},
                          outcome.upperBand = if(band){object$absRisk.upperBand}else{NULL},
                          newdata = newdata,
                          status = NULL,
                          strata = object$strata,
                          times = object$times,
                          name.outcome = "absRisk",
                          group.by = group.by,
                          digits = digits
                          )

    gg.res <- predict2plot(dataL = dataL,
                           name.outcome = "absRisk", # must not contain space to avoid error in ggplot2
                           ci = ci,
                           band = band,
                           group.by = group.by,
                           conf.level = object$conf.level,
                           alpha = alpha,
                           smooth = smooth,
                           xlab = "time",
                           ylab = "absolute risk",
                           ...
                           )
      
  if(plot){
    print(gg.res$plot)
  }
  
  return(invisible(gg.res))
}

#----------------------------------------------------------------------
### autoplot.predictCSC.R ends here
