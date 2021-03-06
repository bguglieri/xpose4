% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/xpose.gam.R
\name{xpose.gam}
\alias{xpose.gam}
\title{Stepwise GAM search for covariates on a parameter (Xpose 4)}
\usage{
xpose.gam(object, parnam = xvardef("parms", object)[1],
  covnams = xvardef("covariates", object), trace = TRUE, scope = NULL,
  disp = object@Prefs@Gam.prefs$disp,
  start.mod = object@Prefs@Gam.prefs$start.mod, family = "gaussian",
  wts.data = object@Data.firstonly, wts.col = NULL,
  steppit = object@Prefs@Gam.prefs$steppit, subset = xsubset(object),
  onlyfirst = object@Prefs@Gam.prefs$onlyfirst,
  medianNorm = object@Prefs@Gam.prefs$medianNorm,
  nmods = object@Prefs@Gam.prefs$nmods,
  smoother1 = object@Prefs@Gam.prefs$smoother1,
  smoother2 = object@Prefs@Gam.prefs$smoother2,
  smoother3 = object@Prefs@Gam.prefs$smoother3,
  smoother4 = object@Prefs@Gam.prefs$smoother4,
  arg1 = object@Prefs@Gam.prefs$arg1, arg2 = object@Prefs@Gam.prefs$arg2,
  arg3 = object@Prefs@Gam.prefs$arg3, arg4 = object@Prefs@Gam.prefs$arg4,
  excl1 = object@Prefs@Gam.prefs$excl1,
  excl2 = object@Prefs@Gam.prefs$excl2,
  excl3 = object@Prefs@Gam.prefs$excl3,
  excl4 = object@Prefs@Gam.prefs$excl4,
  extra = object@Prefs@Gam.prefs$extra, ...)
}
\arguments{
\item{object}{An xpose.data object.}

\item{parnam}{ONE (and only one) model parameter name.}

\item{covnams}{Covariate names to test on parameter.}

\item{trace}{TRUE if you want GAM output to screen.}

\item{scope}{Scope of the GAM search.}

\item{disp}{If dispersion should be used in the GAM object.}

\item{start.mod}{Starting model.}

\item{family}{Assumption for the parameter distribution.}

\item{wts.data}{Weights on the least squares fitting of parameter vs.
covariate. Often one can use the variances of the individual parameter
values as weights. This data frame must have column with name ID and any
subset variable as well as the variable defined by the \code{wts.col}.}

\item{wts.col}{Which column in the \code{wts.data} to use.}

\item{steppit}{TRUE for stepwise search, false for no search.}

\item{subset}{Subset on data.}

\item{onlyfirst}{TRUE if only the first row of each individual's data is to
be used.}

\item{medianNorm}{Normalize to the median of parameter and covariates.}

\item{nmods}{Number of models to examine.}

\item{smoother1}{Smoother for each model.}

\item{smoother2}{Smoother for each model.}

\item{smoother3}{Smoother for each model.}

\item{smoother4}{Smoother for each model.}

\item{arg1}{Argument for model 1.}

\item{arg2}{Argument for model 2.}

\item{arg3}{Argument for model 3.}

\item{arg4}{Argument for model 4.}

\item{excl1}{Covariate exclusion from model 1.}

\item{excl2}{Covariate exclusion from model 2.}

\item{excl3}{Covariate exclusion from model 3.}

\item{excl4}{Covariate exclusion from model 4.}

\item{extra}{Extra exclusion criteria.}

\item{\dots}{Used to pass arguments to more basic functions.}
}
\value{
Returned is a \code{\link[gam]{step.gam}} object
}
\description{
Function takes an Xpose object and performs a generalized additive model
(GAM) stepwise search for influential covariates on a single model parameter.
}
\examples{
## Run a GAM using the example xpose database 
gam_ka <- xpose.gam(simpraz.xpdb, parnam="KA")

## Summarize GAM
xp.summary(gam_ka)

## GAM residuals of base model vs. covariates
xp.plot(gam_ka)

## An Akaike plot of the results
xp.akaike.plot(gam_ka)

## Studentized residuals
xp.ind.stud.res(gam_ka)

## Individual influence on GAM fit
xp.ind.inf.fit(gam_ka)

## Individual influence on GAM terms
xp.ind.inf.terms(gam_ka)

## Individual parameters to GAM fit
xp.cook(gam_ka)

}
\seealso{
\code{\link[gam]{step.gam}}

Other GAM functions: \code{\link{GAM_summary_and_plot}},
  \code{\link{xp.get.disp}}, \code{\link{xp.scope3}},
  \code{\link{xpose.bootgam}}, \code{\link{xpose4-package}}
}
\author{
E. Niclas Jonsson, Mats Karlsson, Andrew Hooker & Justin Wilkins
}
