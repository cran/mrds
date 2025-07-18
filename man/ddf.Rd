% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ddf.R
\name{ddf}
\alias{ddf}
\title{Distance Detection Function Fitting}
\usage{
ddf(
  dsmodel = call(),
  mrmodel = call(),
  data,
  method = "ds",
  meta.data = list(),
  control = list(),
  call = NULL
)
}
\arguments{
\item{dsmodel}{distance sampling model specification}

\item{mrmodel}{mark-recapture model specification}

\item{data}{dataframe containing data to be analyzed}

\item{method}{analysis method}

\item{meta.data}{list containing settings controlling data structure}

\item{control}{list containing settings controlling model fitting}

\item{call}{not implemented for top level ddf function, this is set by ddf as it is passed to the other ddf generics.}
}
\value{
model object of class=(method, "ddf")
}
\description{
Generic function for fitting detection functions for distance sampling with
single and double observer configurations. Independent observer, trial and
dependent observer (removal) configurations are included. This is a generic
function which does little other than to validate the calling arguments and
methods and then calls the appropriate \code{method} specific function to do
the analysis.
}
\details{
The fitting code has certain expectations about \code{data}.  It should be a
dataframe with at least the following fields named and defined as follows:
\tabular{ll}{ \code{object} \tab object number \cr
              \code{observer} \tab observer number (1 or 2) for double
              observer; only 1 if single observer \cr
              \code{detected} \tab 1 if detected by the observer and 0 if
              missed; always 1 for single observer \cr
              \code{distance} \tab perpendicular distance\cr }
If the data are for clustered objects, the dataframe should also contain a
field named \code{size} that gives the observed number in the cluster. If
the data are for a double observer survey, then there are two records for
each observation and each should have the same object number. The code
assumes the observations are listed in the same order for each observer such
that if the data are subsetted by \code{observer} there will be the same
number of records in each and each subset will be in the same \code{object}
order. In addition to these predefined and pre-named fields, the dataframe
can have any number and type of fields that are used as covariates in the
\code{dsmodel} and \code{mrmodel}. At present, discrepancies between
observations in \code{distance}, \code{size} and any user-specified
covariates cannot be assimilated into the uncertainty of the estimate. The
code presumes the values for those fields are the same for both records
(observer=1 and observer=2) and it uses the value from observer 1. Thus it
makes sense to make the values the same for both records in each pair even
when both detect the object or when observer 1 doesn't detect the object the
data would have to be taken from observer 2 and would not be consistent.

Five different fitting methods are currently available and these in turn
define whether \code{dsmodel} and \code{mrmodel} need to be defined.

\tabular{llll}{
Method          \tab Single/Double \tab \code{dsmodel} \tab \code{mrmodel}\cr
\code{ds}       \tab    Single     \tab      yes       \tab    no \cr
\code{io}       \tab    Double     \tab      yes       \tab    yes \cr
\code{io.fi}    \tab    Double     \tab      no        \tab    yes \cr
\code{trial}    \tab    Double     \tab      yes       \tab    yes \cr
\code{trial.fi} \tab    Double     \tab      no        \tab    yes \cr
\code{rem}      \tab    Double     \tab      yes       \tab    yes \cr
\code{rem.fi}   \tab    Double     \tab      no        \tab    yes \cr }

Methods with the suffix "\code{.fi}" use the assumption of full independence
and do not use the distance sampling portion of the likelihood which is why a
\code{dsmodel} is not needed. An \code{mrmodel} is only needed for double
observer surveys and thus is not needed for method \code{ds}.

The \code{dsmodel} specifies the detection function g(y) for the distance
sampling data and the models restrict g(0)=1. For single observer data g(y)
is the detection function for the single observer and if it is a double
observer survey it is the relative detection function (assuming g(0)=1) of
both observers as a team (the unique observations from both observers). In
double observer surveys, the detection function is p(y)=p(0)g(y) such that
p(0)<1.  The detection function g(y) is specified by \code{dsmodel} and p(0)
estimated from the conditional detection functions (see \code{mrmodel}
below).  The value of \code{dsmodel} is specified using a hybrid
formula/function notation.  The model definition is prefixed with a \code{~}
and the remainder is a function definition with specified arguments.  At
present there are two different functions, \code{\link{cds}} and
\code{\link{mcds}}, for conventional distance sampling and multi-covariate
distance sampling.  Both functions have the same required arguments
(\code{key},\code{formula}).  The first specifies the key function this
can be half-normal ("hn"), hazard-rate ("hr"), gamma ("gamma") or uniform
("unif"). The argument \code{formula} specifies the formula
for the log of the scale parameter of the key function (e.g., the equivalent
of the standard deviation in the half-normal).  The variable \code{distance}
should not be included in the formula because the scale is for distance.
See \insertCite{marques2004;textual}{mrds} for more details on the
representation of the scale formula. For the hazard rate and gamma
functions, an additional \code{shape.formula} can be specified for the model
of the shape parameter.  The default will be ~1.
Adjustment terms can be specified by setting \code{adj.series} which can have
the values: "none", "cos" (cosine), "poly" (polynomials), and "herm" 
(Hermite polynomials). One must also specify a vector of orders for the
adjustment terms (\code{adj.order}) and a scaling (\code{adj.scale}) which
may be "width" or "scale" (for scaling by the scale parameter). Note that 
the uniform key can only be used with adjustments (usually cosine adjustments
for a Fourier-type analysis).

The \code{mrmodel} specifies the form of the conditional detection functions
(i.e.,probability it is seen by observer j given it was seen by observer
3-j) for each observer (j=1,2) in a double observer survey.  The value is
specified using the same mix of formula/function notation but in this case
the functions are \code{glm} and \code{gam}.  The arguments for the
functions are \code{formula} and \code{link}.  At present, only \code{glm}
is allowed and it is restricted to \code{link=logit}.  Thus, currently the
only form for the conditional detection functions is logistic as expressed
in eq 6.32 of \insertCite{laake2004;textual}{mrds}.  In contrast to \code{dsmodel}, the
argument \code{formula} will typically include \code{distance} and all other
covariates that affect detection probability.  For example,
\code{mrmodel=~glm(formula=~distance+size+sex)} constructs a conditional
detection function based on the logistic form with additive factors,
distance, size, and sex.  As another example,
\code{mrmodel=~glm(formula=~distance*size+sex)} constructs the same model
with an added interaction between distance and size.

The argument \code{meta.data} is a list that enables various options about
the data to be set. These options include:

\describe{
 \item{\code{point}}{if \code{TRUE} the data are from point counts and
 \code{FALSE} (default) implies line transect data}
 \item{\code{width}}{distance specifying half-width of the transect}
 \item{\code{left}}{distance specifying inner truncation value}
 \item{\code{binned}}{\code{TRUE} or \code{FALSE} to specify whether
 distances should be binned for analysis}
 \item{\code{breaks}}{if \code{binned=TRUE}, this is a required sequence of
 break points that are used for plotting/gof. They should match
 \code{distbegin}, \code{distend} values if bins are fixed}
 \item{\code{int.range}}{an integration range for detection probability;
 either a vector of 2 or matrix with 2 columns}
 \item{\code{mono}}{constrain the detection function to be weakly
 monotonically decreasing (only applicable when there are no covariates in
 the detection function)}
 \item{\code{mono.strict}}{when \code{TRUE} constrain the detection function
 to be strictly monotonically decreasing (again, only applicable when there
 are no covariates in the detection function)}
}

Using \code{meta.data=list(int.range=c(1,10))} is the same as
\code{meta.data=list(left=1,width=10)}. If
\code{meta.data=list(binned=TRUE)} is used, the dataframe needs to contain
the fields distbegin and distend for each observation which specify the left
and right hand end points of the distance interval containing the
observation. This is a general data structure that allows the intervals to
change rather than being fixed as in the standard distance analysis tools.
Typically, if the intervals are changing so is the integration range.  For
example, assume that distance bins are generated using fixed angular
measurements from an aircraft in which the altitude is varying.  Because all
analyses are truncated (i.e., the last interval does not go to infinity),
the transect width (and the left truncation point if there is a blindspot
below the aircraft) can potentially change for each observation. The
argument \code{int.range} can also be entered as a matrix with 2 columns
(left and width) and a row for each observation.

The argument \code{control} is a list that enables various analysis options
to be set.  It is not necessary to set any of these for most analyses.  They
were provided so the user can optionally see intermediate fitting output and
to control fitting if the algorithm doesn't converge which happens
infrequently.  The list values include:

\describe{
  \item{\code{showit}}{Integer (0-3, default 0) controls the
  (increasing)amount of information printed during fitting. 0 - none, >=1 -
  information about refitting and bound changes is printed, >=2 -
  information about adjustment term fitting is printed, ==3 -per-iteration
  parameter estimates and log-likelihood printed.}
  \item{\code{estimate}}{if FALSE fits model but doesn't estimate predicted
  probabilities}
  \item{\code{refit}}{if TRUE the algorithm will attempt multiple
  optimizations at different starting values if it doesn't converge}
  \item{\code{nrefits}}{number of refitting attempts}
  \item{\code{initial}}{a named list of starting values for the dsmodel
  parameters (e.g. \code{$scale}, \code{$shape}, \code{$adjustment})}
  \item{\code{lowerbounds}}{a vector of lowerbounds for the dsmodel 
  parameters in the order the ds parameters will appear in the par 
  element of the ddf object, i.e. \code{fit.ddf$par} where \code{fit.ddf} 
  is a fitted ddf model.}
  \item{\code{upperbounds}}{a vector of upperbounds for the dsmodel 
  parameters in the order the ds parameters will appear in the par 
  element of the ddf object, i.e. \code{fit.ddf$par} where \code{fit.ddf} 
  is a fitted ddf model.}
  \item{\code{limit}}{if TRUE restrict analysis to observations with
  \code{detected}=1}
  \item{\code{debug}}{ if TRUE, if fitting fails, return an object with
  fitting information}
  \item{\code{nofit}}{if TRUE don't fit a model, but use the starting values
  and generate an object based on those values}
  \item{\code{optimx.method}}{one (or a vector of) string(s) giving the
  optimisation method to use. If more than one is supplied, the results from
  one are used as the starting values for the next. See
  \code{\link[optimx]{optimx}}}
  \item{\code{optimx.maxit}}{maximum number of iterations to use in the
  optimisation.}
  \item{\code{mono.random.start}}{By default when monotonicity constraints
  are enforced, a grid of starting values are tested. Instead random
  starting values can be used (uniformly distributed between the upper and
  lower bounds). Set \code{TRUE} for random start, \code{FALSE} (default)
  uses the grid method}
  \item{\code{mono.method}}{The optimiser method to be used when (strict) 
  monotonicity is enforced. Can be either \code{slsqp} or \code{solnp}. 
  Default \code{slsqp}.}
  \item{\code{mono.startvals}}{Controls if the mono.optimiser should find 
  better starting values by first fitting a key function without adjustments, 
  and then use those start values for the key function parameters when 
  fitting the key + adjustment series detection function. Defaults to 
  \code{FALSE}}
  \item{\code{mono.outer.iter}}{Number of outer iterations to be used by
  \code{solnp} when fitting a monotonic model and \code{solnp} is selected. 
  Default 200.}
  \item{\code{silent}}{silences warnings within ds fitting method (helpful
  for running many times without generating many warning/error messages).}
  \item{\code{optimizer}}{By default this is set to 'both' for single 
  observer analyses and 'R' for double observer analyses. For single 
  observer analyses where optimizer = 'both', the R optimizer will be used 
  and if present the MCDS optimizer will also be used. The result with the 
  best likelihood value will be selected. To run only a specified optimizer 
  set this value to either 'R' or 'MCDS'. The MCDS optimizer cannot currently
  be used for detection function fitting with double observer analyses.  
  See \code{\link{mcds_dot_exe}} for more information.}
  \item{\code{winebin}}{Location of the \code{wine} binary used to run
  \code{MCDS.exe}. See \link{mcds_dot_exe} for more information.}
}

Examples of distance sampling analyses are available at
\url{https://distancesampling.org/resources/vignettes.html}.

Hints and tips on fitting (particularly optimisation issues) are on the
\code{\link{mrds_opt}} manual page.
}
\examples{
# load data
data(book.tee.data)
region <- book.tee.data$book.tee.region
egdata <- book.tee.data$book.tee.dataframe
samples <- book.tee.data$book.tee.samples
obs <- book.tee.data$book.tee.obs

# fit a half-normal detection function
result <- ddf(dsmodel=~mcds(key="hn", formula=~1), data=egdata, method="ds",
              meta.data=list(width=4))

# fit an independent observer model with full independence
result.io.fi <- ddf(mrmodel=~glm(~distance), data=egdata, method="io.fi",
                    meta.data=list(width = 4))

# fit an independent observer model with point independence
result.io <- ddf(dsmodel=~cds(key = "hn"), mrmodel=~glm(~distance),
                 data=egdata, method="io", meta.data=list(width=4))
\dontrun{

# simulated single observer point count data (see ?ptdata.single)
data(ptdata.single)
ptdata.single$distbegin <- (as.numeric(cut(ptdata.single$distance,
                            10*(0:10)))-1)*10
ptdata.single$distend <- (as.numeric(cut(ptdata.single$distance,
                          10*(0:10))))*10
model <- ddf(data=ptdata.single, dsmodel=~cds(key="hn"),
             meta.data=list(point=TRUE,binned=TRUE,breaks=10*(0:10)))

summary(model)

plot(model,main="Single observer binned point data - half normal")

model <- ddf(data=ptdata.single, dsmodel=~cds(key="hr"),
             meta.data=list(point=TRUE, binned=TRUE, breaks=10*(0:10)))

summary(model)

plot(model, main="Single observer binned point data - hazard rate")

dev.new()

# simulated double observer point count data (see ?ptdata.dual)
# setup data
data(ptdata.dual)
ptdata.dual$distbegin <- (as.numeric(cut(ptdata.dual$distance,
                          10*(0:10)))-1)*10
ptdata.dual$distend <- (as.numeric(cut(ptdata.dual$distance,
                        10*(0:10))))*10

model <- ddf(method="io", data=ptdata.dual, dsmodel=~cds(key="hn"),
             mrmodel=~glm(formula=~distance*observer),
             meta.data=list(point=TRUE, binned=TRUE, breaks=10*(0:10)))

summary(model)

plot(model, main="Dual observer binned point data", new=FALSE, pages=1)

model <- ddf(method="io", data=ptdata.dual,
             dsmodel=~cds(key="unif", adj.series="cos", adj.order=1),
             mrmodel=~glm(formula=~distance*observer),
             meta.data=list(point=TRUE, binned=TRUE, breaks=10*(0:10)))

summary(model)

par(mfrow=c(2,3))
plot(model,main="Dual observer binned point data",new=FALSE)

}
}
\references{
\insertAllCited{}
}
\seealso{
\code{\link{ddf.ds}}, \code{\link{ddf.io}},
\code{\link{ddf.io.fi}}, \code{\link{ddf.trial}},
\code{\link{ddf.trial.fi}}, \code{\link{ddf.rem}}, \code{\link{ddf.rem.fi}},
\code{\link{mrds_opt}}
}
\author{
Jeff Laake
}
\keyword{Models}
\keyword{~Statistical}
