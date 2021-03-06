% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/confint.predictCox.R
\name{confint.predictCox}
\alias{confint.predictCox}
\title{Confidence Intervals and Confidence Bands for the predicted Survival/Cumulative Hazard}
\usage{
\method{confint}{predictCox}(
  object,
  parm = NULL,
  level = 0.95,
  n.sim = 10000,
  cumhazard.transform = "log",
  survival.transform = "loglog",
  seed = NA,
  ...
)
}
\arguments{
\item{object}{A \code{predictCox} object, i.e. output of the \code{predictCox} function.}

\item{parm}{[character] the type of predicted value for which the confidence intervals should be output.
Can be \code{"survival"} or \code{"cumhazard"}.}

\item{level}{[numeric, 0-1] Level of confidence.}

\item{n.sim}{[integer, >0] the number of simulations used to compute the quantiles for the confidence bands.}

\item{cumhazard.transform}{[character] the transformation used to improve coverage
of the confidence intervals for the cumlative hazard in small samples.
Can be \code{"none"}, \code{"log"}.}

\item{survival.transform}{[character] the transformation used to improve coverage
of the confidence intervals for the survival in small samples.
Can be \code{"none"}, \code{"log"}, \code{"loglog"}, \code{"cloglog"}.}

\item{seed}{[integer, >0] seed number set before performing simulations for the confidence bands.
If not given or NA no seed is set.}

\item{...}{not used.}
}
\description{
Confidence intervals and confidence Bands for the predicted survival/cumulative Hazard.
}
\details{
The confidence bands and confidence intervals are automatically restricted to the interval of definition of the statistic,
i.e. a confidence interval for the survival of [0.5;1.2] will become [0.5;1].
}
\examples{
library(survival)

#### generate data ####
set.seed(10)
d <- sampleData(40,outcome="survival") 

#### estimate a stratified Cox model ####
fit <- coxph(Surv(time,event)~X1 + strata(X2) + X6,
             data=d, ties="breslow", x = TRUE, y = TRUE)

#### compute individual specific survival probabilities  
fit.pred <- predictCox(fit, newdata=d[1:3], times=c(3,8), type = "survival",
                       se = TRUE, iid = TRUE, band = TRUE)
fit.pred

## check standard error
sqrt(rowSums(fit.pred$survival.iid[,,1]^2)) ## se for individual 1

## check confidence interval
newse <- fit.pred$survival.se/(-fit.pred$survival*log(fit.pred$survival))
cbind(lower = as.double(exp(-exp(log(-log(fit.pred$survival)) + 1.96 * newse))),
      upper = as.double(exp(-exp(log(-log(fit.pred$survival)) - 1.96 * newse)))
)

#### compute confidence intervals without transformation
confint(fit.pred, survival.transform = "none")
cbind(lower = as.double(fit.pred$survival - 1.96 * fit.pred$survival.se),
      upper = as.double(fit.pred$survival + 1.96 * fit.pred$survival.se)
)

}
\author{
Brice Ozenne
}
