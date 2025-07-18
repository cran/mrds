#' Density and abundance estimates and variances
#'
#' Compute density and abundance estimates and variances based on
#' Horvitz-Thompson-like estimator.
#'
#' Density and abundance within the sampled region is computed based on a
#' Horvitz-Thompson-like estimator for groups and individuals (if a clustered
#' population) and this is extrapolated to the entire survey region based on
#' any defined regional stratification. The variance is based on replicate
#' samples within any regional stratification. For clustered populations,
#' \eqn{E(s)} and its standard error are also output.
#'
#' Abundance is estimated with a Horvitz-Thompson-like estimator (\insertCite{huggins1989;nobrackets}{mrds}; \insertCite{huggins1991;nobrackets}{mrds}; \insertCite{borchers1998;nobrackets}{mrds}; \insertCite{borchers2004;nobrackets}{mrds}). The abundance in the
#' sampled region is simply \eqn{1/p_1 + 1/p_2 + ... + 1/p_n} where \eqn{p_i}
#' is the estimated detection probability for the \eqn{i}th detection of
#' \eqn{n} total observations. It is not strictly a Horvitz-Thompson estimator
#' because the \eqn{p_i} are estimated and not known. For animals observed in
#' tight clusters, that estimator gives the abundance of groups
#' (\code{group=TRUE} in \code{options}) and the abundance of individuals is
#' estimated as \eqn{s_1/p_1 + s_2/p_2 + ... + s_n/p_n}, where \eqn{s_i} is the
#' size (e.g., number of animals in the group) of each observation
#' (\code{group=FALSE} in \code{options}).
#'
#' Extrapolation and estimation of abundance to the entire survey region is
#' based on either a random sampling design or a stratified random sampling
#' design. Replicate samples (lines) are specified within regional strata
#' \code{region.table}, if any. If there is no stratification,
#' \code{region.table} should contain only a single record with the \code{Area}
#' for the entire survey region. The \code{sample.table} is linked to the
#' \code{region.table} with the \code{Region.Label}. The \code{obs.table} is
#' linked to the \code{sample.table} with the \code{Sample.Label} and
#' \code{Region.Label}. Abundance can be restricted to a subset (e.g., for a
#' particular species) of the population by limiting the list the observations
#' in \code{obs.table} to those in the desired subset. Alternatively, if
#' \code{Sample.Label} and \code{Region.Label} are in the \code{data.frame}
#' used to fit the model, then a \code{subset} argument can be given in place
#' of the \code{obs.table}. To use the \code{subset} argument but include all
#' of the observations, use \code{subset=1==1} to avoid creating an
#' \code{obs.table}.
#'
#' In extrapolating to the entire survey region it is important that the unit
#' measurements be consistent or converted for consistency. A conversion factor
#' can be specified with the \code{convert.units} variable in the
#' \code{options} list. The values of \code{Area} in \code{region.table}, must
#' be made consistent with the units for \code{Effort} in \code{sample.table}
#' and the units of \code{distance} in the \code{data.frame} that was analyzed.
#' It is easiest to do if the units of \code{Area} is the square of the units
#' of \code{Effort} and then it is only necessary to convert the units of
#' \code{distance} to the units of \code{Effort}. For example, if \code{Effort}
#' was entered in kilometres and \code{Area} in square kilometres and
#' \code{distance} in metres then using
#' \code{options=list(convert.units=0.001)} would convert metres to kilometres,
#' density would be expressed in square kilometres which would then be
#' consistent with units for \code{Area}. However, they can all be in different
#' units as long as the appropriate composite value for \code{convert.units} is
#' chosen. Abundance for a survey region can be expressed as: \code{A*N/a}
#' where \code{A} is \code{Area} for the survey region, \code{N} is the
#' abundance in the covered (sampled) region, and \code{a} is the area of the
#' sampled region and is in units of \code{Effort * distance}. The sampled
#' region \code{a} is multiplied by \code{convert.units}, so it should be
#' chosen such that the result is in the same units of \code{Area}. For
#' example, if \code{Effort} was entered in kilometres, \code{Area} in hectares
#' (100m x 100m) and \code{distance} in metres, then using
#' \code{options=list(convert.units=10)} will convert \code{a} to units of
#' hectares (100 to convert metres to 100 metres for distance and .1 to convert
#' km to 100m units).
#'
#' The argument \code{options} is a list of \code{variable=value} pairs that
#' set options for the analysis. All but two of these have been described above.
#' \code{pdelta} should not need to be changed but was included for
#' completeness. It controls the precision of the first derivative calculation
#' for the delta method variance. If the option \code{areas.supplied} is
#' \code{TRUE} then the covered area is assumed to be supplied in the
#' \code{CoveredArea} column of the sample \code{data.frame}.
#'
#' @section Uncertainty:
#' If the argument \code{se=TRUE}, standard errors for density and abundance is
#' computed. Coefficient of variation and log-normal confidence intervals are
#' constructed using a Satterthwaite approximation for degrees of freedom
#' (\insertCite{buckland2001;nobrackets}{mrds} p 90). The function \code{\link{dht.se}} computes the
#' variance and interval estimates.
#'
#' The variance has two components:
#' \itemize{
#'   \item variation due to uncertainty from estimation of the detection
#'   function parameters;
#'   \item variation in abundance due to random sample selection;
#' }
#' The first component (model parameter uncertainty) is computed using a delta
#' method estimate of variance (\insertCite{huggins1989;nobrackets}{mrds}; \insertCite{huggins1991;nobrackets}{mrds}; \insertCite{borchers1998;nobrackets}{mrds}) in
#' which the first derivatives of the abundance estimator with respect to the
#' parameters in the detection function are computed numerically (see
#' \code{\link{DeltaMethod}}).
#'
#' The second component (encounter rate variance) can be computed in one of
#' several ways depending on the form taken for the encounter rate and the
#' estimator used. To begin with there three possible values for \code{varflag}
#' to calculate encounter rate:
#' \itemize{
#'  \item \code{0} uses a binomial variance for the number of observations
#'  (equation 13 of \insertCite{borchers1998;nobrackets}{mrds}. This estimator is only useful if the
#'  sampled region is the survey region and the objects are not clustered; this
#'  situation will not occur very often;
#'  \item \code{1} uses the encounter rate \eqn{n/L} (objects observed per unit
#'  transect) from \insertCite{buckland2001;textual}{mrds} pg 78-79 (equation 3.78) for line
#'  transects (see also \insertCite{fewster2009;nobrackets}{mrds} estimator R2). This variance
#'  estimator is not appropriate if \code{size} or a derivative of \code{size}
#'  is used in the detection function;
#'  \item \code{2} is the default and uses the encounter rate estimator
#'  \eqn{\hat{N}/L} (estimated abundance per unit transect) suggested by \insertCite{innes2002;textual}{mrds} and \insertCite{marques2004;textual}{mrds} 
#' }
#'
#' In general if any covariates are used in the models, the default
#' \code{varflag=2} is preferable as the estimated abundance will take into
#' account variability due to covariate effects. If the population is clustered
#' the mean group size and standard error is also reported.
#'
#' For options \code{1} and \code{2}, it is then possible to choose one of the
#' estimator forms given in \insertCite{fewster2009;textual}{mrds} 
#' for line transects:
#' \code{"R2"}, \code{"R3"}, \code{"R4"}, \code{"S1"}, \code{"S2"},
#' \code{"O1"}, \code{"O2"} or \code{"O3"} can be used by specifying \code{ervar} 
#' in the list of options provided by the \code{options} argument 
#' (default \code{"R2"}). For points, either the \code{"P2"} or 
#' \code{"P3"} estimator can be selected (>=mrds 2.3.0 default \code{"P2"},
#' <= mrds 2.2.9 default \code{"P3"}). See \code{\link{varn}} and \insertCite{fewster2009;textual}{mrds} for further details on these estimators.
#'
#' @param model ddf model object
#' @param region.table \code{data.frame} of region records. Two columns:
#' \code{Region.Label} and \code{Area}. If only density is required, one can
#' set \code{Area=0} for all regions.
#' @param sample.table \code{data.frame} of sample records. Three columns:
#' \code{Region.Label}, \code{Sample.Label}, \code{Effort}.
#' @param obs.table \code{data.frame} of observation records with fields:
#' \code{object}, \code{Region.Label}, and \code{Sample.Label} which give links
#' to \code{sample.table}, \code{region.table} and the data records used in
#' \code{model}. Not necessary if the \code{data.frame} used to create the
#' model contains \code{Region.Label}, \code{Sample.Label} columns.
#' @param subset subset statement to create \code{obs.table}
#' @param se if \code{TRUE} computes standard errors, coefficient of variation
#' and confidence intervals (based on log-normal approximation). See
#' "Uncertainty" below.
#' @param options a list of options that can be set, see "\code{dht} options",
#' below.
#' @return list object of class \code{dht} with elements:
#' \item{clusters}{result list for object clusters}
#' \item{individuals}{result list for individuals}
#' \item{Expected.S}{\code{data.frame} of estimates of expected cluster size
#'  with fields \code{Region}, \code{Expected.S} and \code{se.Expected.S}
#'  If each cluster \code{size=1}, then the result only includes individuals
#'  and not clusters and \code{Expected.S}.}
#'
#' The list structure of clusters and individuals are the same:
#' \item{bysample}{\code{data.frame} giving results for each sample;
#' \code{Sample.Area} is the covered area associated with the sampler,
#' \code{n} is the number of detections on the sampler,
#' \code{Nhat} is the estimated abundance within the sample, and 
#' \code{Dhat} is \eqn{\frac{Nhat}{\sum{Sample.Area}}} so that summing 
#' these values gives the overall density estimates.}
#' 
#' \item{summary}{\code{data.frame} of summary statistics for each region and
#' total. Note that the summary statistics give a general summary of the data 
#' and may use more basic calculations than those used in the abundance
#' and density calculations.}
#' \item{N}{\code{data.frame} of estimates of abundance for each region and
#' total}
#' \item{D}{\code{data.frame} of estimates of density for each region and total}
#' \item{average.p}{average detection probability estimate}
#' \item{cormat}{correlation matrix of regional abundance/density estimates and
#' total (if more than one region)}
#' \item{vc}{list of 3: total variance-covariance matrix, detection function
#' component of variance and encounter rate component of variance. For
#' detection the v-c matrix and partial vector are returned}
#' \item{Nhat.by.sample}{another summary of \code{Nhat} by sample used by
#' \code{\link{dht.se}}}
#'
#'
#' @section \code{dht} options:
#'  Several options are available to control calculations and output:
#'
#' \describe{
#'  \item{\code{ci.width}}{Confidence interval width, expressed as a decimal
#'  between 0 and 1 (default \code{0.95}, giving a 95\% CI)}
#'  \item{\code{pdelta}}{delta value for computing numerical first derivatives
#'  (Default: 0.001)}
#'  \item{\code{varflag}}{0,1,2 (see "Uncertainty") (Default: \code{2})}
#'  \item{\code{convert.units}}{ multiplier for width to convert to units of
#'  length (Default: \code{1})}
#'  \item{\code{ervar}}{encounter rate variance type (see "Uncertainty" and
#'  \code{type} argument of \code{\link{varn}}). (Default: \code{"R2"} for
#'  lines and \code{"P2"} for points)}
#'}
#'
#' @author Jeff Laake, David L Miller
#' @seealso \code{\link{print.dht}} \code{\link{dht.se}}
#' @references
#' \insertAllCited{}
#' @keywords utility
#' @importFrom stats aggregate
#' @importFrom Rdpack reprompt
#' @export
dht <- function(model, region.table, sample.table, obs.table=NULL, subset=NULL,
                se=TRUE, options=list()){
  # Functions Used:  assign.default.values, create.varstructure,
  #                  covered.region.dht, survey.region.dht, dht.se, varn,
  #                  covn(in varn.R), solvecov (in coef.ds.R).

  tables.dht <- function(group){
    # Internal function to create summary tables for clusters (group=TRUE) or
    # individuals (group=FALSE).
    options$group <- group

    # Compute covered region abundances by sample depending on value of group
    Nhat.by.sample <- covered.region.dht(obs, samples, group)

    # Mod 18-Aug-05 jll; added computation of avergage detection probability
    # which is simply n/Nhat in the covered region
    average.p <- nrow(obs)/sum(Nhat.by.sample$Nhat)

    width <- model$meta.data$width * options$convert.units
    left <- model$meta.data$left * options$convert.units

    # Scale up abundances to survey region
    Nhat.by.sample <- survey.region.dht(Nhat.by.sample, samples, width,
                                        left, point, options$areas.supplied)
    # sort Nhat.by.sample by Region.Label and Sample.Label
    Nhat.by.sample <- Nhat.by.sample[order(Nhat.by.sample$Region.Label,
                                           Nhat.by.sample$Sample.Label), ]

    bysample.table <- with(Nhat.by.sample,
                           data.frame(Region      = Region.Label,
                                      Area        = Area,
                                      Sample      = Sample.Label,
                                      Effort      = Effort.x,
                                      Sample.Area = CoveredArea,
                                      n           = n,
                                      Nhat       = Nhat*CoveredArea/Area))

    # Calculate density contributions (these can be summed to give overall density)
    bysample.table$Dhat <- bysample.table$Nhat/bysample.table$Sample.Area
    # Now update CoveredArea so it's per sample
    if(point){
      bysample.table$Sample.Area <- pi*bysample.table$Effort*width^2 - pi*bysample.table$Effort*left^2
    }else{
      bysample.table$Sample.Area <- 2*bysample.table$Effort*(width-left)
    }
    
    Nhat.by.region <- as.numeric(by(Nhat.by.sample$Nhat,
                                    Nhat.by.sample$Region.Label, sum))

    # Create estimate table
    numRegions <- length(unique(region.table$Region.Label))
    if(numRegions > 1){
      estimate.table <- data.frame(
                          Label = c(levels(unique(samples$Region.Label)),
                                    "Total"),
                          Estimate = rep(0, numRegions + 1),
                          se = rep(NA,numRegions + 1),
                          cv = rep(NA, numRegions + 1),
                          lcl = rep(NA,numRegions + 1),
                          ucl = rep(NA, numRegions + 1))
    }else{
      estimate.table <- data.frame(Label    = c("Total"),
                                   Estimate = rep(0, 1),
                                   se       = rep(NA, 1),
                                   cv       = rep(NA, 1),
                                   lcl      = rep(NA, 1),
                                   ucl      = rep(NA, 1))
    }

    if(numRegions > 1){
      estimate.table$Estimate <- c(Nhat.by.region, sum(Nhat.by.region))
    }else{
      estimate.table$Estimate <- Nhat.by.region
    }

    # Create summary table
    summary.table <- Nhat.by.sample[, c("Region.Label", "Area",
                                        "CoveredArea", "Effort.y")]
    summary.table <- unique(summary.table)

    if(!all(region.table$Region.Label %in% summary.table$Region.Label)){
      summary.table <- rbind(summary.table,
                             cbind(region.table[!(region.table$Region.Label %in%
                                                  summary.table$Region.Label),
                                                c("Region.Label", "Area")],
                                   0, 0))
    }
    # ER variance for each stratum, total below
    var.er <- sapply(split(Nhat.by.sample, Nhat.by.sample$Region.Label),
                     function(x) varn(x$Effort.x, x$n, type=options$ervar))


    #  jll 11_11_04; change to set missing values for nobs to 0
    #   - regions with no sightings
    nobs <- as.vector(by(bysample.table$n, bysample.table$Region, sum))
    nobs[is.na(nobs)] <- 0
    summary.table$n <- nobs
    summary.table$k <- tapply(Nhat.by.sample$Sample.Label,
                              Nhat.by.sample$Region.Label, length)
    summary.table$k[is.na(summary.table$CoveredArea)] <- 0
    colnames(summary.table) <- c("Region", "Area", "CoveredArea",
                                 "Effort", "n", "k")

    # calculate encounter rate
    er <- summary.table$n/summary.table$Effort

    # get totals of easy stuff
    if(numRegions > 1){
      summary.table <- data.frame(Region=c(levels(summary.table$Region),
                                           "Total"),
                                  rbind(summary.table[, -1],
                                        apply(summary.table[, -1], 2, sum)))
    }

    # get total encounter rate and its variance
    if(numRegions > 1){
      er <- c(er, sum(er * summary.table$Area[1:length(er)])/
                    sum(summary.table$Area[1:length(er)]))
      total.var.er <- sum(var.er * summary.table$Area[1:length(var.er)]^2)/
                        sum(summary.table$Area[1:length(var.er)])^2
      var.er <- c(var.er, total.var.er)
    }

    summary.table$ER <- er
    summary.table$se.ER <- sqrt(var.er)
    summary.table$cv.ER <- summary.table$se.ER/summary.table$ER
    summary.table$cv.ER[summary.table$ER==0] <- 0

    # set missing values to 0
    summary.table$ER[is.nan(summary.table$ER)] <- 0
    summary.table$se.ER[is.nan(summary.table$se.ER)] <- 0
    summary.table$cv.ER[is.nan(summary.table$cv.ER)] <- 0

    # If summary of individuals for a clustered popn, add mean
    # group size and its std error
    if(!group){
      mean.clustersize <- tapply(obs$size, obs$Region.Label, mean)
      se.clustersize <- sqrt(tapply(obs$size, obs$Region.Label, var)/
                             tapply(obs$size, obs$Region.Label, length))
      cs <- data.frame(Region    = names(mean.clustersize),
                       mean.size = as.vector(mean.clustersize),
                       se.mean   = as.vector(se.clustersize))

      summary.table <- merge(summary.table, cs, by.x = "Region",
                             all=TRUE, sort=FALSE)

      if(numRegions > 1){
        summary.table$mean.size[numRegions+1] <- mean(obs$size)
        summary.table$se.mean[numRegions+1] <- sqrt(var(obs$size)/
                                                length(obs$size))
      }
      # 29/05/12 lhm - moved to set missing values to 0
      summary.table$mean.size[is.na(summary.table$mean.size)] <- 0
      summary.table$se.mean[is.na(summary.table$se.mean)] <- 0
    }

    rownames(summary.table) <- 1:dim(summary.table)[1]

    # If a std error has been requested call dht.se
    if(se){
      result <- dht.se(model, summary.table, samples, obs, options, numRegions,
                       estimate.table, Nhat.by.sample)
      estimate.table <- result$estimate.table
    }

    # Create estimate table for D from same table for N
    D.estimate.table <- estimate.table
    if(numRegions > 1){
      D.estimate.table$Estimate <- D.estimate.table$Estimate/
                                    c(region.table$Area, sum(region.table$Area))
      D.estimate.table$se <- D.estimate.table$se/
                               c(region.table$Area, sum(region.table$Area))
      D.estimate.table$lcl <- D.estimate.table$lcl/
                               c(region.table$Area, sum(region.table$Area))
      D.estimate.table$ucl <- D.estimate.table$ucl/
                               c(region.table$Area, sum(region.table$Area))
    }else{
      D.estimate.table$Estimate <- D.estimate.table$Estimate/region.table$Area
      D.estimate.table$se <- D.estimate.table$se/region.table$Area
      D.estimate.table$lcl <- D.estimate.table$lcl/region.table$Area
      D.estimate.table$ucl <- D.estimate.table$ucl/region.table$Area
    }

    # set missing values to 0
    D.estimate.table$Estimate[is.nan(D.estimate.table$Estimate)] <- 0
    D.estimate.table$se[is.nan(D.estimate.table$se)] <- 0
    D.estimate.table$cv[is.nan(D.estimate.table$cv)] <- 0
    D.estimate.table$lcl[is.nan(D.estimate.table$lcl)] <- 0
    D.estimate.table$ucl[is.nan(D.estimate.table$ucl)] <- 0

    # Return list depending on value of se
    # change to set missing values to 0
    # jll 6/30/06; dropped restriction that numregions > 1 on sending vc back
    if(se){
      cormat <- result$vc/(result$estimate.table$se %o%
                           result$estimate.table$se)
      cormat[is.nan(cormat)] <- 0
      result <- list(bysample=bysample.table, summary = summary.table,
                     N=result$estimate.table, D=D.estimate.table,
                     average.p=average.p, cormat = cormat,
                     vc=list(total     = result$vc,
                             detection = result$vc1,
                             er        = result$vc2),
                     Nhat.by.sample=Nhat.by.sample)
    }else{
      result <- list(bysample=bysample.table, summary=summary.table,
                     N=estimate.table, D=D.estimate.table, average.p=average.p,
                     Nhat.by.sample=Nhat.by.sample)
    }
    return(result)
  }

###Start of dht function

  # Assign default values to options
  options <- assign.default.values(options, pdelta=0.001, varflag=2,
                                   convert.units=1,
                                   ervar=ifelse(model$meta.data$point, "P2",
                                                "R2"),
                                   areas.supplied=FALSE)
  
  # Input checking
  # Check that the object field is numeric in the obs.table
  if(!is.null(obs.table)){
    if(!is.numeric(obs.table$object)){
      warning("Please ensure the object field in the obs.table is numeric, cannot perform dht calculations.", call. = FALSE)
      return(NULL)
    }
  }

  # jll 18-Nov-04; the following allows for a subset statement to be added to
  # create obs.table from model data rather than creating obs.table separately.
  # This only works if the data contain the Sample.Label and Region.Label
  # fields.
  point <- model$meta.data$point
  objects <- as.numeric(names(model$fitted))
  if(is.null(obs.table)){
    data <- model$data
    if("observer"%in%names(data)){
      # jll 3 Sept 2014 if dual observer I added code to use observer 1 only
      # or it was doubling sample size
      data <- data[data$observer==1, ]
    }
    if("Sample.Label" %in% names(data) & "Region.Label" %in% names(data)){
      if(is.null(substitute(subset))){
         obs.table <- data[, c("object", "Sample.Label", "Region.Label")]
      }else{
         select <- data[eval(substitute(subset),envir=data), ]
         obs.table <- select[, c("object", "Sample.Label", "Region.Label")]
      }
      obs.table <- obs.table[obs.table$object %in% objects, ]
    }else{
      stop("Must specify obs.table because Sample.Label and/or Region.Label fields not contained in data")
    }
  }

  # Extract relevant fields from Region and Sample tables; jll 4 May 07;
  region.table <- region.table[, c("Region.Label", "Area")]
  if(options$areas.supplied){
    sample.table <- sample.table[, c("Region.Label", "Sample.Label", "Effort",
                                     "CoveredArea")]
  }else{
    sample.table <- sample.table[, c("Region.Label", "Sample.Label", "Effort")]
  }

  # Make sure input data labels are factors
  region.table$Region.Label <- factor(region.table$Region.Label)
  sample.table$Region.Label <- factor(sample.table$Region.Label,
                                      levels=levels(region.table$Region.Label))
  obs.table$Region.Label <- factor(obs.table$Region.Label,
                                   levels=levels(region.table$Region.Label))
  sample.table$Sample.Label <- factor(sample.table$Sample.Label)
  obs.table$Sample.Label <- factor(obs.table$Sample.Label,
                                   levels=levels(sample.table$Sample.Label))


  # P2 and P3 can only be used with points
  if((options$ervar=="P3" || options$ervar=="P2") && !model$meta.data$point){
    stop("Encounter rate variance estimator P2 / P3 may only be used with point transects, set with options=list(ervar=...)")
  }

  # switch to the P2 estimator if using points
  if(model$meta.data$point){
    if(!(options$ervar %in% c("P2", "P3"))){
      warning("Point transect encounter rate variance can only use estimators P2 or P3, switching to P2.")
      options$ervar <- "P2"
    }
  }

  # If area is zero for all regions reset to the area of the covered region
  DensityOnly <- FALSE
  if(sum(region.table$Area)==0){
    # Convert width value (needed here to set the area)
    width <- (model$meta.data$width-model$meta.data$left)*options$convert.units
    DensityOnly <- TRUE
    # cat("Warning: Area for regions is zero. They have been set to area of covered region(strips), \nso N is for covered region.",
    #     "However, standard errors will not match \nprevious covered region SE because it includes spatial variation\n")
    # this is a bit fiddly as ordering is not guaranteed
    Effort.by.region <- aggregate(sample.table$Effort,
                                  list(sample.table$Region.Label), sum)
    names(Effort.by.region) <- c("Region.Label", "Effort")
    Effort.by.region$Area <- if(point){
      pi*Effort.by.region$Effort*width^2
    }else{
      2*Effort.by.region$Effort*width
    }
    region.table$Area <- NULL
    region.table <- merge(region.table, Effort.by.region, by="Region.Label")
    region.table$Effort <- NULL
  }
  
  # Create obs/samples structures
  vs <- create.varstructure(model, region.table, sample.table, obs.table, se)
  samples <- vs$samples
  obs <- vs$obs
  region.table <- vs$region
  
  # handle subset feature when labels are also in data
  if(!is.null(obs$Region.Label.x)){
    obs$Region.Label <- obs$Region.Label.x
    obs$Sample.Label <- obs$Sample.Label.x
    obs$Region.Label.x <- NULL
    obs$Sample.Label.x <- NULL
    obs$Region.Label.y <- NULL
    obs$Sample.Label.y <- NULL
  }
  
  # Merge with fitted values
  pdot <- model$fitted
  obs <- merge(obs, data.frame(object=objects, pdot=pdot))
  
  # If clustered population create tables for clusters and individuals and
  # an expected S table otherwise just tables for individuals in an
  # unclustered popn
  if(!is.null(obs$size)){
    clusters <- tables.dht(TRUE)
    individuals <- tables.dht(FALSE )
    Expected.S <- individuals$N$Estimate/clusters$N$Estimate
    
    # This computes the se(E(s)). It essentially uses 3.37 from Ads but in
    # place of using 3.25, 3.34 and 3.38, it uses 3.27, 3.35 and an equivalent
    # cov replacement term for 3.38. This uses line to line variability
    # whereas the other formula measure the variance of E(s) within the lines
    # and it goes to zero as p approaches 1.
    if(se & options$varflag!=1){
      
        numRegions <- length(unique(samples$Region.Label))
        if(options$varflag==2){
          cov.Nc.Ncs <- rep(0, numRegions)
          scale <- clusters$summary$Area/clusters$summary$CoveredArea
          
          for(i in 1:numRegions){
            c.stratum.data <- clusters$Nhat.by.sample[
              as.character(clusters$Nhat.by.sample$Region.Label) ==
                as.character(region.table$Region.Label[i]), ]
            
            i.stratum.data <- individuals$Nhat.by.sample[
              as.character(individuals$Nhat.by.sample$Region.Label) ==
                as.character(region.table$Region.Label[i]), ]
            
            Li <- sum(c.stratum.data$Effort.x)
            cov.Nc.Ncs[i] <- covn(c.stratum.data$Effort.x/(scale[i]*Li),
                                  c.stratum.data$Nhat/scale[i],
                                  i.stratum.data$Nhat/scale[i],
                                  options$ervar)
          }
        }else{
          cov.Nc.Ncs <- as.vector(by(obs$size*(1 - obs$pdot)/obs$pdot^2,
                                     obs$Region.Label, sum))
          cov.Nc.Ncs[is.na(cov.Nc.Ncs)] <- 0
        }
        
        cov.Nc.Ncs[is.nan(cov.Nc.Ncs)] <- 0
        if(numRegions > 1){
          cov.Nc.Ncs <- c(cov.Nc.Ncs, sum(cov.Nc.Ncs))
        }
        if(model$method == "ds" && model$ds$aux$ddfobj$type == "unif" && is.null(model$ds$aux$ddfobj$adjustment)){
          # if fitting a uniform with no adjustments the covariance is 0
          cov.Nc.Ncs <- 0
        }else{
          cov.Nc.Ncs <- cov.Nc.Ncs +
            diag(t(clusters$vc$detection$partial)%*%
                   solvecov(model$hessian)$inv%*%
                   individuals$vc$detection$partial)
        }
        se.Expected.S <- as.vector(clusters$N$cv)^2 +
          as.vector(individuals$N$cv)^2 -
          2*cov.Nc.Ncs/
          (as.vector(individuals$N$Estimate)*
             as.vector(clusters$N$Estimate))
        Expected.S[is.nan(Expected.S)] <- 0
        se.Expected.S[se.Expected.S<=0 | is.nan(se.Expected.S)] <- 0
        se.Expected.S <- as.vector(Expected.S)*sqrt(se.Expected.S)
        
        Expected.S <- data.frame(Region        = clusters$N$Label,
                                 Expected.S    = as.vector(Expected.S),
                                 se.Expected.S = as.vector(se.Expected.S))
    }else{
      Expected.S[is.nan(Expected.S)] <- 0
      Expected.S <- data.frame(Region     = clusters$N$Label,
                               Expected.S = as.vector(Expected.S))
    }

    if(DensityOnly){
      clusters$N <- NULL
      individuals$N <- NULL
    }

    result <- list(clusters    = clusters,
                   individuals = individuals,
                   Expected.S  = Expected.S)
  }else{
    individuals <- tables.dht(TRUE)
    if(DensityOnly){
      individuals$N <- NULL
    }
    result <- list(individuals=individuals)
  }
  
  # Check to see if need to issue user with a warning if there were any strata with only one sample.
  if(any(result$individuals$summary$k == 1)){
    # if there is only one strata
    if(nrow(result$individuals$summary) == 1){
      if(options$varflag == 1){
        warning("Only one sample, assuming variance of n is Poisson. See help on dht.se for recommendations.", immediate. = TRUE, call. = FALSE)
      }else if(options$varflag == 2){
        warning("Only one sample, assuming abundance in the covered region is Poisson. See help on dht.se for recommendations.", immediate. = TRUE, call. = FALSE)
      }
    }else{
      # if there are multiple strata
      # find which strata have only one sample
      strat.names <- result$individuals$summary$Region[result$individuals$summary$k == 1]
      strat.txt <- ifelse(length(strat.names) > 1, ". For these strata, ", ". For this stratum, ")
      if(options$varflag == 1){
        warning(paste("Only one sample in the following strata: ", paste(strat.names, collapse = ", "), strat.txt, "it is assumed variance of n is Poisson. See help on dht.se.", sep = ""), immediate. = TRUE, call. = FALSE)
      }else if(options$varflag == 2){
        warning("Only one sample in the following strata: ", paste(strat.names, collapse = ", "), strat.txt, "it is assumed abundance in the covered region is Poisson. See help on dht.se.", immediate. = TRUE, call. = FALSE)
      }
    } 
  }

  # add some meta data
  # save enounter rate variance information
  attr(result, "ER_var") <- c(options$ervar, options$varflag==2,
                              options$varflag==0)

  class(result) <- "dht"
  return(result)
}
