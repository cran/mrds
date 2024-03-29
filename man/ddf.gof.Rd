% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ddf.gof.R
\name{ddf.gof}
\alias{ddf.gof}
\alias{gof.io}
\alias{gof.io.fi}
\alias{gof.trial}
\alias{gof.trial.fi}
\alias{gof.rem}
\alias{gof.rem.fi}
\title{Goodness of fit tests for distance sampling models}
\usage{
ddf.gof(
  model,
  breaks = NULL,
  nc = NULL,
  qq = TRUE,
  nboot = 100,
  ks = FALSE,
  ...
)
}
\arguments{
\item{model}{model object}

\item{breaks}{Cutpoints to use for binning data}

\item{nc}{Number of distance classes}

\item{qq}{Flag to indicate whether quantile-quantile plot is desired}

\item{nboot}{number of replicates to use to calculate p-values for the
Kolmogorov-Smirnov goodness of fit test statistics}

\item{ks}{perform the Kolmogorov-Smirnov test (this involves many bootstraps
so can take a while)}

\item{\dots}{Graphics parameters to pass into qqplot function}
}
\value{
List of class \code{ddf.gof} containing \item{chi-square }{Goodness
of fit test statistic} \item{df}{Degrees of freedom associated with test
statistic} \item{p-value }{Significance level of test statistic}
}
\description{
Generic function that computes chi-square goodness of fit test for detection
function models with binned data and Cramer-von Mises and Kolmogorov-Smirnov
(if \code{ks=TRUE})tests for exact distance data. By default a Q-Q plot is
generated for exact data (and can be suppressed using the \code{qq=FALSE}
argument).
}
\details{
Formal goodness of fit testing for detection function models using
Kolmogorov-Smirnov and Cramer-von Mises tests. Both tests are based on
looking at the quantile-quantile plot produced by \code{\link{qqplot.ddf}}
and deviations from the line x=y.

The Kolmogorov-Smirnov test asks the question "what's the largest vertical
distance between a point and the y=x line?" It uses this distance as a
statistic to test the null hypothesis that the samples (EDF and CDF in our
case) are from the same distribution (and hence our model fits well). If the
deviation between the y=x line and the points is too large we reject the
null hypothesis and say the model doesn't have a good fit.

Rather than looking at the single biggest difference between the y=x line
and the points in the Q-Q plot, we might prefer to think about all the
differences between line and points, since there may be many smaller
differences that we want to take into account rather than looking for one
large deviation. Its null hypothesis is the same, but the statistic it uses
is the sum of the deviations from each of the point to the line.
Note that a bootstrap procedure is required for the Kolmogorov-Smirnov test
to ensure that the p-values from the procedure are correct as the we are
comparing the cumulative distribution function (CDF) and empirical
distribution function (EDF) and we have estimated the parameters of the
detection function. The \code{nboot} parameter controls the number of
bootstraps to use. Set to \code{0} to avoid computing bootstraps (much
faster but with no Kolmogorov-Smirnov results, of course).

One can change the precision of printed values by using the \code{\link{print.ddf.gof}} method's \code{digits} argument.
}
\seealso{
\code{\link{qqplot.ddf}}
}
\author{
Jeff Laake
}
\keyword{utility}
