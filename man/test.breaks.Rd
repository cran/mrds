% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test.breaks.R
\name{test.breaks}
\alias{test.breaks}
\title{Test validity for histogram breaks(cutpoints)}
\usage{
test.breaks(breaks, left, width)
}
\arguments{
\item{breaks}{vector of cutpoints (breaks) for distance histogram}

\item{left}{left truncation value}

\item{width}{right truncation value; either radius of point count or
half-width of transect}
}
\value{
vector of breaks modified to be valid if necessary
}
\description{
Determines whether user specified breaks for histograms are properly ordered
and match the left and right truncation.
}
\author{
Jeff Laake
}
