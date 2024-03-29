% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/covered.region.dht.R
\name{covered.region.dht}
\alias{covered.region.dht}
\title{Covered region estimate of abundance from Horvitz-Thompson-like estimator}
\usage{
covered.region.dht(obs, samples, group)
}
\arguments{
\item{obs}{observations table}

\item{samples}{samples table}

\item{group}{if TRUE compute abundance of group otherwise abundance of
individuals}
}
\value{
Nhat.by.sample - dataframe of abundance by sample
}
\description{
Computes H-T abundance within covered region by sample.
}
\note{
Internal function called by \code{\link{dht}} and related functions
}
\author{
Jeff Laake
}
\keyword{utility}
