% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create.varstructure.R
\name{create.varstructure}
\alias{create.varstructure}
\title{Creates structures needed to compute abundance and variance}
\usage{
create.varstructure(model, region, sample, obs, dht.se)
}
\arguments{
\item{model}{fitted ddf object}

\item{region}{region table}

\item{sample}{sample table}

\item{obs}{table of object #'s and links to sample and region table}

\item{dht.se}{is uncertainty going to be calculated later?}
}
\value{
List with 2 elements: \item{samples }{merged dataframe containing
  region and sample info - one record per sample} \item{obs}{merged
  observation data and links to region and samples}
}
\description{
Creates samples and obs dataframes used to compute abundance and its
variance based on a structure of geographic regions and samples within each
region.  The intent is to generalize this routine to work with other
sampling structures.
}
\details{
The function performs the following tasks: 1)tests to make sure that region
labels are unique, 2) merges sample and region tables into a samples table
and issue a warning if not all samples were used, 3) if some regions have no
samples or if some values of Area were not valid areas given then issue
error and stop, then an error is given and the code stops, 4) creates a
unique region/sample label in samples and in obs, 5) merges observations
with sample and issues a warning if not all observations were used, 6) sorts
regions by its label and merges the values with the predictions from the
fitted model based on the object number and limits it to the data that is
appropriate for the fitted detection function.
}
\note{
Internal function called by \code{\link{dht}}
}
\author{
Jeff Laake
}
\keyword{utility}
