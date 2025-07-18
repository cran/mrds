#' Variance and confidence intervals for density and abundance estimates
#'
#' Computes standard error, cv, and log-normal confidence intervals for
#' abundance and density within each region (if any) and for the total of all
#' the regions. It also produces the correlation matrix for regional and total
#' estimates.
#'
#' The variance has two components:
#' \itemize{
#'   \item variation due to uncertainty from estimation of the detection
#'   function parameters;
#'   \item variation in abundance due to random sample selection.
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
#'  \item \code{0} uses a negative binomial variance for the number of 
#'  observations (equation 13 of \insertCite{borchers1998;nobrackets}{mrds}). 
#'  This estimator is only 
#'  useful if the sampled region is the survey region and the objects are not 
#'  clustered; this situation will not occur very often;
#'  \item \code{1} uses the encounter rate \eqn{n/L} (objects observed per unit
#'  transect) from \insertCite{buckland2001;textual}{mrds} pg 78-79 (equation 3.78) for line
#'  transects (see also \insertCite{fewster2009;nobrackets}{mrds} estimator R2). This variance
#'  estimator is not appropriate if \code{size} or a derivative of \code{size}
#'  is used in the detection function;
#'  \item \code{2} is the default and uses the encounter rate estimator
#'  \eqn{\hat{N}/L} (estimated abundance per unit transect) suggested by
#'  \insertCite{innes2002;textual}{mrds} and \insertCite{marques2004;textual}{mrds}.
#' }
#'
#' In general if any covariates are used in the models, the default
#' \code{varflag=2} is preferable as the estimated abundance will take into
#' account variability due to covariate effects. If the population is clustered
#' the mean group size and standard error is also reported.
#'
#' For options \code{1} and \code{2}, it is then possible to choose one of the
#' estimator forms given in \insertCite{fewster2009;textual}{mrds}. For line transects:
#' \code{"R2"}, \code{"R3"}, \code{"R4"}, \code{"S1"}, \code{"S2"},
#' \code{"O1"}, \code{"O2"} or \code{"O3"} can be used by specifying \code{ervar} 
#' in the list of options provided by the \code{options} argument 
#' (default \code{"R2"}). For points, either the 
#' \code{"P2"} or \code{"P3"} estimator can be selected (>=mrds 2.3.0 
#' default \code{"P2"}, <= mrds 2.2.9 default \code{"P3"}). See 
#' \code{\link{varn}} and \insertCite{fewster2009;textual}{mrds}
#'  for further details on these estimators.
#'
#' Exceptions to the above occur if there is only one sample in a stratum. In
#' this situation, \code{varflag=0} continues to use a negative binomial
#' variance while the other options assume a Poisson variance (\eqn{Var(x)=x}), 
#' where when \code{varflag=1} x is number of detections in the covered region and 
#' when \code{varflag=2} x is the abundance in the covered region. It also assumes 
#' a known variance so \eqn{z=1.96} is used for critical value. In all other cases 
#' the degrees of freedom for the \eqn{t}-distribution assumed for the
#' log(abundance) or log(density) is based on the Satterthwaite approximation
#' (\insertCite{buckland2001;nobrackets}{mrds} pg 90) for the degrees of freedom (df). The df are
#' weighted by the squared cv in combining the two sources of variation because
#' of the assumed log-normal distribution because the components are
#' multiplicative. For combining df for the sampling variance across regions
#' they are weighted by the variance because it is a sum across regions.
#' 
#' The coefficient of variation (CV) associated with the abundance estimates is calculated based on the following formula for the \code{varflag} options 1 and 2:
#' 
#' \code{varflag=1}
#' 
#' \deqn{CV(\hat{N}) = \sqrt{\left(\frac{\sqrt{n}}{n}\right)^2+CV(\hat{p})^2}}
#' 
#' \code{varflag=2}
#' 
#' \deqn{CV(\hat{N}) = \sqrt{\left(\frac{\sqrt{\hat{N}}}{\hat{N}}\right)^2+CV(\hat{p})^2}}
#' where n is the number of observations, \eqn{\hat{N}} is the estimated
#' abundance and \eqn{\hat{p}} is the average probability of detection for
#' an animal in the covered area. 
#'
#' A non-zero correlation between regional estimates can occur from using a
#' common detection function across regions. This is reflected in the
#' correlation matrix of the regional and total estimates which is given in the
#' value list. It is only needed if subtotals of regional estimates are needed.
#'
#' @param model ddf model object
#' @param region.table table of region values
#' @param samples table of samples(replicates)
#' @param obs table of observations
#' @param options list of options that can be set (see \code{\link{dht}})
#' @param numRegions number of regions
#' @param estimate.table table of estimate values
#' @param Nhat.by.sample estimated abundances by sample
#' @export
#' @return List with 2 elements: \item{estimate.table}{completed table with se,
#' cv and confidence limits} \item{vc }{correlation matrix of estimates}
#' @note This function is called by \code{dht} and it is not expected that the
#' user will call this function directly but it is documented here for
#' completeness and for anyone expanding the code or using this function in
#' their own code.
#' @author Jeff Laake
#' @seealso \code{\link{dht}}, \code{\link{print.dht}}
#' @references 
#' \insertAllCited{}
#' @keywords utility
#' @importFrom stats qnorm qt var
#' @importFrom Rdpack reprompt
dht.se <- function(model, region.table, samples, obs, options, numRegions,
                   estimate.table, Nhat.by.sample){
  #  Functions Used:  DeltaMethod, dht.deriv (in DeltaMethod), varn

  # Define function: compute.df
  compute.df <- function(k, type){
    if(type=="O1" | type=="O2"| type=="O3"){
      H.O <- k - 1
      k.h.O <- rep(2, H.O)
      df <- sum(k.h.O - 1)
    }else{
      if(type=="S1" | type=="S2"){
        H.S <- floor(k/2)
        k.h.S <- rep(2, H.S)
        if(k %% 2 > 0) k.h.S[H.S] <- 3
        df <- sum(k.h.S - 1)
      }else{
        df <- k-1
      }
    }
    return(df)
  }

  # First compute variance component due to estimation of detection function
  # parameters. This uses the delta method and produces a v-c matrix if more
  # than one strata
  if(!is.null(model$par)){
    vcov <- solvecov(model$hessian)$inv
    vc1.list <- DeltaMethod(model$par, dht.deriv, vcov, options$pdelta,
                            model=model, samples=samples, obs=obs,
                            options=options)
    vc1 <- vc1.list$variance
  }else{
    vc1.list <- list(variance=0)
    vc1 <- 0
  }

  # Next compute the component due to sampling of both lines and of the
  # detection process itself
  # There are 3 different options here:
  #  1) varflag=0; Negative binomial variance of detection process - only
  # applicable if survey region=covered region although it will scale up 
  # but it would be
  #   a poor estimator
  #  2) varflag=1; delta method, with varn based on Fewster et al (2009)
  #   estimator R2 (var(n/L))
  #  3) varflag=2; Innes et al variance estimator (var(N/L), except changed to
  #   resemble the form of estimator R2 of Fewster et al (2009))
  # Exceptions to the above occur if there is only one sample in a stratum.
  #   In that case it uses Poisson approximation.

  scale <- region.table$Area/region.table$CoveredArea

  # If no areas were given or varflag=0 use approach #1
  # Note: vc2 is of proper dimension because Region.Label for obs is setup
  # with all levels of the Region.Label from the region.table.
  if(sum(region.table$Area) == 0 | options$varflag == 0){
    if(options$group){
      vc2 <- by((1 - obs$pdot)/obs$pdot^2, obs$Region.Label, sum)
    }else{
      vc2 <- by(obs$size^2 * (1 - obs$pdot)/obs$pdot^2, obs$Region.Label, sum)
    }
    # set missing value to 0
    vc2[is.na(vc2)] <- 0

    if(sum(region.table$Area) != 0){
      vc2 <- vc2 * scale[1:numRegions]^2
    }
  }else{
    # Otherwise compute variance for varflag=1 or 2
    vc2 <- rep(0, numRegions)
    # 26 jan 06 jll; changed to use object rather than distance; also
    # overwrites existing n because that can be sum(size) rather than count
    nobs <- tapply(obs$object, obs$Label, length)
    nobs <- data.frame(Label = names(nobs),
                       n = as.vector(nobs)[!is.na(nobs)])
    Nhat.by.sample$n <- NULL
    # when there are no sighings
    if(nrow(nobs) > 0){
      Nhat.by.sample <- merge(Nhat.by.sample, nobs, by.x = "Label",
                              by.y = "Label", all.x = TRUE)
      Nhat.by.sample$n[is.na(Nhat.by.sample$n)] <- 0
    }else{
      Nhat.by.sample <- cbind(Nhat.by.sample, n = rep(0, nrow(Nhat.by.sample)))
    }

    # Compute number of lines per region for df calculation
    if(numRegions > 1){
      estimate.table$k <- c(as.vector(tapply(samples$Effort,
                                             samples$Region.Label, length)), 0)
      estimate.table$k[numRegions + 1] <- sum(estimate.table$k)
    }else{
      estimate.table$k <- as.vector(tapply(samples$Effort,
                                           samples$Region.Label, length))
    }

    # If individual abundance being computed, calculate mean and variance
    # of mean for group size.
    if(!options$group){
      if(length(obs$size) > 0){
        ngroup <- by(obs$size, obs$Region.Label, length)
        vars <- by(obs$size, obs$Region.Label, var)/ngroup
        sbar <- by(obs$size, obs$Region.Label, mean)
        sobs <- data.frame(Region.Label = names(sbar),
                           vars         = as.vector(vars),
                           sbar         = as.vector(sbar),
                           ngroup       = as.vector(ngroup))
      }else{
        sobs <- data.frame(Region.Label = levels(obs$Region.Label),
                           vars = rep(NA, length(levels(obs$Region.Label))),
                           sbar = rep(NA, length(levels(obs$Region.Label))),
                           ngroup = NA)
      }
      Nhat.by.sample <- merge(Nhat.by.sample, sobs, by.x = "Region.Label",
                              by.y = "Region.Label", all.x = TRUE)
      Nhat.by.sample$sbar[is.na(Nhat.by.sample$sbar)] <- 0
      Nhat.by.sample$vars[is.na(Nhat.by.sample$vars)] <- 0
    }else{
      # If group abundance is being estimated, set mean=1, var=0
      Nhat.by.sample$sbar <- rep(1, nrow(Nhat.by.sample))
      Nhat.by.sample$vars <- rep(0, nrow(Nhat.by.sample))
    }

    # sort Nhat.by.sample by Region.Label and Sample.Label
    Nhat.by.sample <- Nhat.by.sample[order(Nhat.by.sample$Region.Label,
                                           Nhat.by.sample$Sample.Label), ]

    # Loop over each region and compute each variance;
    # jll 11/11/04 - changes made in following code using
    # Effort.x (effort per line) rather than previous errant code
    # that used Effort.y (effort per region)
    if(!options$group) vg <- rep(0, numRegions)
    for(i in 1:numRegions){
      stratum.data <- Nhat.by.sample[as.character(Nhat.by.sample$Region.Label)==
                                     as.character(region.table$Region[i]), ]
      Ni <- sum(stratum.data$Nhat)
      Li <- sum(stratum.data$Effort.x)
      sbar <- stratum.data$sbar[1]
      vars <- stratum.data$vars[1]

      if (options$group) vars <- 0

      # if there is only one sample assume Poisson variance
      if(length(stratum.data$Effort.y) == 1){
        if (options$varflag == 1){
          # Assuming variance of n is Poisson: var(x) = x
          vc2[i] <- Ni^2 * 1/stratum.data$n
        }else{
          # varflag = 2
          # Assuming abundance in covered region is Poisson: var(x) = x
          vc2[i] <- Ni^2 * 1/Ni
        }
      }else if (options$varflag == 1){
        # Buckland et al 2001 using n/L
        vc2[i] <- (Ni * Li)^2 * varn(stratum.data$Effort.x,
                                     stratum.data$n, type=options$ervar)/
                                sum(stratum.data$n)^2

        if(!options$group){
          # if we have groups, add in the variance components (when estimating
          # density/abundance of individuals)
          vg[i] <- Ni^2 * vars/sbar^2
        }
      }else{
        # Innes et al estimator using N/L
        vc2[i] <- varn(stratum.data$Effort.x/(scale[i] * Li),
                       stratum.data$Nhat/scale[i], type=options$ervar)
      }
    }
  }

  vc2[is.nan(vc2)] <- 0

  # Construct v-c matrix for encounter rate variance given computed ps
  # The cov between regional estimate and total estimate is simply var for
  #  regional estimate.
  # Assumes no cov between regions due to independent sample selection.
  if(numRegions > 1){
    v2 <- vc2
    vc2 <- diag(c(vc2, sum(vc2)))
    vc2[1:numRegions, (numRegions + 1)] <- v2
    vc2[(numRegions + 1), 1:numRegions] <- v2
    if(!options$group & options$varflag==1){
      vg[is.nan(vg)] <- 0
      vg <- diag(c(vg, sum(vg)))
    }
  }else if (length(vc2) > 1){
    vc2 <- diag(vc2)
  }else{
    vc2 <- as.matrix(vc2)
  }

  vc <- vc1 + vc2
  # for the Buckland estimator, when we have groups add in the groups
  # variance component
  if(!options$group & options$varflag==1){
    vc <- vc + vg
  }

  # deal with missing values and 0 estimates.
  estimate.table$se <- sqrt(diag(vc))
  estimate.table$se[is.nan(estimate.table$se)] <- 0
  estimate.table$cv <- estimate.table$se/estimate.table$Estimate
  estimate.table$cv[is.nan(estimate.table$cv)] <- 0

  # work out the confidence intervals
  # if the options$ci.width is set, then use that, else default to
  # 95% CI
  if(is.null(options$ci.width)){
    ci.width <- 0.025
  }else{
    ci.width <- (1-options$ci.width)/2
  }

  # Use satterthwaite approx for df and log-normal distribution for
  # 95% intervals
  if(options$varflag != 0){
    # set df from replicate lines to a min of 1 which avoids divide by zero
    # Following 2 lines added and references to estimate.table$k changed to df
    df <- estimate.table$k
    df <- sapply(df, compute.df, type=options$ervar)
    df[df<1] <- 1

    if(any(is.na(vc1)) || all(vc1==0)){
      estimate.table$df <- df
    }else{
      # loop over the strata, calculating the components of the df calc
      # see Buckland et al. (2001) Eqn 3.75
      for(i in 1:numRegions){
        cvs <- c(sqrt(diag(vc1)[i])/estimate.table$Estimate[i],
                 sqrt(diag(vc2)[i])/estimate.table$Estimate[i])
        df_cvs <- c(length(model$fitted)-length(model$par), df[i])

        # add in group size component if we need to
        if(!options$group & options$varflag==1){
          cvs <- c(cvs, sqrt(sobs$vars[i])/sobs$sbar[i])
          df_cvs <- c(df_cvs, sobs$ngroup[i]-1)
        }
        estimate.table$df[i] <- estimate.table$cv[i]^4 / sum((cvs^4)/df_cvs)
      }
    }

    # compute proper satterthwaite
    # df for total estimate assuming sum of indep region estimates; uses
    # variances instead of cv's because it is a sum of means for encounter
    # rate portion of variance (df.total)
    if(numRegions>1){
      df.total <- (diag(vc2)[numRegions+1])^2/
                   sum((diag(vc2)^2/df)[1:numRegions])
      if(all(vc1==0)){
          estimate.table$df[numRegions+1] <- df.total
      }else{
        cvs <- c(sqrt(diag(vc1)[numRegions+1])/
                   estimate.table$Estimate[numRegions+1],
                 sqrt(diag(vc2)[numRegions+1])/
                   estimate.table$Estimate[numRegions+1])
        df_cvs <- c(length(model$fitted)-length(model$par), df.total)

        # add in group size component if we need to
        if(!options$group & options$varflag==1){
          cvs <- c(cvs, sqrt(vg[numRegions+1, numRegions+1])/
                             estimate.table$Estimate[numRegions+1])
          df_cvs <- c(df_cvs, length(model$fitted)-1)
        }
        estimate.table$df[numRegions+1] <- estimate.table$cv[numRegions+1]^4 /
                                            sum((cvs^4)/df_cvs)
      }
    }

    estimate.table$df[estimate.table$df < 1 &estimate.table$df >0] <- 1
    cvalue <- exp((abs(qt(ci.width, estimate.table$df)) *
                  sqrt(log(1 + estimate.table$cv^2))))
  }else{
    # intervals for varflag=0; sets df=0
    # and uses normal approximation
    cvalue <- exp((abs(qnorm(ci.width)) * sqrt(log(1 + estimate.table$cv^2))))
    estimate.table$df <- rep(0, dim(estimate.table)[1])
  }

  # deal with missing values and divide by 0 issues
  estimate.table$df[is.nan(estimate.table$df)] <- 0
  estimate.table$df[is.na(estimate.table$df)] <- 0
  estimate.table$lcl  <-  estimate.table$Estimate/cvalue
  estimate.table$lcl[is.nan(estimate.table$lcl)] <- 0
  estimate.table$lcl[is.na(estimate.table$lcl)] <- 0
  estimate.table$ucl  <-  estimate.table$Estimate * cvalue
  estimate.table$ucl[is.nan(estimate.table$ucl)] <- 0
  estimate.table$ucl[is.na(estimate.table$ucl)] <- 0
  estimate.table$k  <-  NULL

  return(list(estimate.table = estimate.table,
              vc             = vc,
              vc1            = vc1.list,
              vc2            = vc2 ))
}
