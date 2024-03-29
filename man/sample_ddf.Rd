% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample_ddf.R
\name{sample_ddf}
\alias{sample_ddf}
\title{Generate data from a fitted detection function and refit the model}
\usage{
sample_ddf(ds.object)
}
\arguments{
\item{ds.object}{a fitted detection function object}
}
\description{
Generate data from a fitted detection function and refit the model
}
\note{
This function changes the random number generator seed. To avoid any
potential side-effects, use something like: \code{seed <-
get(".Random.seed",envir=.GlobalEnv)} before running code and
\code{assign(".Random.seed",seed,envir=.GlobalEnv)} after.
}
\author{
David L. Miller
}
