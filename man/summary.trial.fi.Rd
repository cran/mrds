% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.trial.fi.R
\name{summary.trial.fi}
\alias{summary.trial.fi}
\title{Summary of distance detection function model object}
\usage{
\method{summary}{trial.fi}(object, se = TRUE, N = TRUE, fittedmodel = NULL, ...)
}
\arguments{
\item{object}{a \code{ddf} model object}

\item{se}{if TRUE, computes standard errors}

\item{N}{if TRUE, computes abundance in covered (sampled) region}

\item{fittedmodel}{full fitted model when called from \code{trial} or
\code{io}}

\item{\dots}{unspecified and unused arguments for S3 consistency}
}
\value{
list of extracted and summarized objects
}
\description{
Provides a brief summary of data and fitted detection probability model
parameters, model selection criterion, and optionally abundance in the
covered (sampled) region and its standard error.
}
\details{
The argument \code{N} is used to suppress computation of
abundance and average detection probability in calls to summarize the
\code{ds} and either \code{io.fi} or \code{trial.fi} for summaries of
\code{io} and \code{trial} objects respectively which are composed of a
\code{ds} model object and a mark-recapture model object. The corresponding
print function is called to print the summary results.
}
\note{
This function is called by the generic function \code{summary} for any
  \code{ddf} model object.  Each function can be called directly by the
  user, but it is typically safest to use the generic function
  \code{summary} which calls the appropriate function based on the type of
  \code{ddf} model.
}
\author{
Jeff Laake
}
\keyword{utility}
