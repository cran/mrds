#' CDS/MCDS Distance Detection Function Fitting
#'
#' Fits a conventional distance sampling (CDS) (likelihood eq 6.6 in Laake and
#' Borchers 2004) or multi-covariate distance sampling (MCDS)(likelihood eq
#' 6.14 in Laake and Borchers 2004) model for the detection function of
#' observed distance data.  It only uses key functions and does not incorporate
#' adjustment functions as in CDS/MCDS analysis engines in DISTANCE (Marques
#' and Buckland 2004). Distance can be grouped (binned), ungrouped (unbinned)
#' or mixture of the two.  This function is not called directly by the user and
#' is called from \code{ddf},\code{ddf.io}, or \code{ddf.trial}.
#'
#' For a complete description of each of the calling arguments, see
#' \code{\link{ddf}}.  The argument \code{model} in this function is the same
#' as \code{dsmodel} in \code{ddf}.  The argument \code{dataname} is the name
#' of the dataframe specified by the argument \code{data} in \code{ddf}. The
#' arguments \code{control},\code{meta.data},and \code{method} are defined the
#' same as in \code{ddf}.
#'
#' @export
#' @method ddf ds
#' @param dsmodel model list with key function and scale formula if any
#' @param mrmodel not used
#' @param data \code{data.frame}; see \code{\link{ddf}} for details
#' @param meta.data \code{list} containing settings controlling data structure
#' @param control \code{list} containing settings controlling model fitting
#' @param call original function call if this function not called directly from
#'   \code{ddf} (e.g., called via \code{ddf.io})
#' @param method analysis method; only needed if this function called from
#'   \code{ddf.io} or \code{ddf.trial}
#' @return result: a \code{ds} model object
#' @note If mixture of binned and unbinned distance, width must be set to be >=
#'   largest interval endpoint; this could be changed with a more complicated
#'   analysis; likewise, if all binned and bins overlap, the above must also
#'   hold; if bins don't overlap, width must be one of the interval endpoints;
#'   same holds for left truncation Although the mixture analysis works in
#'   principle it has not been tested via simulation.
#' @author Jeff Laake
#' @seealso \code{\link{flnl}}, \code{\link{summary.ds}}, \code{\link{coef.ds}},
#'   \code{\link{plot.ds}},\code{\link{gof.ds}}
#' @references Laake, J.L. and D.L. Borchers. 2004. Methods for incomplete
#'   detection at distance zero. In: Advanced Distance Sampling, eds. S.T.
#'   Buckland, D.R. Anderson, K.P. Burnham, J.L. Laake, D.L. Borchers, and L.
#'   Thomas. Oxford University Press.
#'
#' Marques, F.F.C. and S.T. Buckland. 2004. Covariate models for the detection
#'   function. In: Advanced Distance Sampling, eds. S.T. Buckland,
#'   D.R. Anderson, K.P. Burnham, J.L. Laake, D.L. Borchers, and L. Thomas.
#'   Oxford University Press.
#' @keywords Statistical Models
#' @examples
#'
#' # ddf.ds is called when ddf is called with method="ds"
#' \donttest{
#' data(book.tee.data)
#' region <- book.tee.data$book.tee.region
#' egdata <- book.tee.data$book.tee.dataframe
#' samples <- book.tee.data$book.tee.samples
#' obs <- book.tee.data$book.tee.obs
#' result <- ddf(dsmodel = ~mcds(key = "hn", formula = ~1),
#'               data = egdata[egdata$observer==1, ], method = "ds",
#'               meta.data = list(width = 4))
#' summary(result,se=TRUE)
#' plot(result,main="cds - observer 1")
#' print(dht(result,region,samples,obs,options=list(varflag=0,group=TRUE),
#'           se=TRUE))
#' print(ddf.gof(result))
#' }

ddf.ds <-function(dsmodel, mrmodel = NULL,
                  data, method="ds", meta.data=list(), 
                  control=list(), call){
  
  # Name changes to match generics
  model <- dsmodel
  #   Code structure for optimization with optim
  #
  # ddf.ds --> detfct.fit --> detfct.fit.opt --> optimx or solnp --> flnl
  #
  # flnl--> flpt.lnl --> distpdf ---> detfct
  #                      gstdint --> integratepdf ---> distpdf
  #                      integratedpdf --> distpdf
  #
  # Detection function and options are described in ddfobj which is
  # created by create.ddfobj. That function creates list structure and
  # sets up initial values.

  ### handle monotonicity before processing default meta.data values
  # if monotonicity is turned on via mono.strict, turn on mono
  if(!is.null(meta.data$mono.strict)){
    if(meta.data$mono.strict){
      meta.data$mono <- TRUE
    }
  }
  # if mono.strict was not set, but mono was TRUE then turn on mono.strict
  if(!is.null(meta.data$mono)){
    if(meta.data$mono & is.null(meta.data$mono.strict)){
      meta.data$mono <- TRUE
    }
  }

  # Set up meta data values
  meta.data <- assign.default.values(meta.data, left=0, width=NA, binned=FALSE,
                                    int.range=NA, mono=FALSE, mono.strict=FALSE,
                                    point=FALSE)

  # Set up control values
  control <- assign.default.values(control, showit=0,
                                   estimate=TRUE, refit=TRUE, nrefits=25,
                                   initial=NA, lowerbounds=NA, upperbounds=NA,
                                   limit=TRUE, parscale=TRUE, maxiter=12,
                                   standardize=TRUE, mono.points=10, ## FTP: 10 instead of 20!
                                   mono.tol=1e-6, mono.delta=1e-7,
                                   mono.outer.iter=200, debug=FALSE,
                                   nofit=FALSE, optimx.method="nlminb",
                                   optimx.maxit=300, silent=FALSE,
                                   mono.random.start=FALSE,
                                   optimizer = "both", 
                                   mono.method = "slsqp", # FTP: add slot for constraint solver (slsqp or solnp)
                                   mono.startvals = FALSE, # FTP: add slot for finding best starting values for constraint solver (default=TRUE, temporarilty set to FALSE)
                                   winebin = NULL)

  #  Save current user options and then set design contrasts to treatment style
  save.options <- options()
  on.exit(options(save.options))
  options(contrasts=c("contr.treatment","contr.poly"))

  # Process data
  # First remove data with missing distances
  if(!is.null(data$distance)){
    data <- data[!is.na(data$distance), ]
  }else{
    data <- data[!is.na(data$distbegin)&!is.na(data$distend), ]
  }
  if(is.null(data$object)){
    stop("\nobject field is missing in the data\n")
  }
  # Next call function to process data based on values of meta.data
  datalist <- process.data(data, meta.data, check=FALSE)
  xmat <- datalist$xmat
  meta.data <- datalist$meta.data

  # use all unique detections (observer=1) if observer is present
  if(!is.null(xmat$observer)){
    if(control$limit){
      if(length(levels(factor(xmat$observer)))>1){
        xmat <- xmat[xmat$observer==levels(factor(xmat$observer))[1],]
        xmat$detected <- rep(1,dim(xmat)[1])
      }
    }
  }

  #  If the frame includes a variable detected, use only those with detected=1
  if(!is.null(xmat$detected)){
    if(control$limit) xmat <- xmat[xmat$detected==1,]
  }else{
    xmat$detected <- rep(1,dim(xmat)[1])
  }

  #  Make sure object #'s are unique
  if(length(unique(xmat$object))!=length(xmat$object)){
    stop("\nSome values of object field are duplicates. They must be unique.\n")
  }

  # check we don't have more parameters than data
  npars <- switch(eval(model[[2]]$key),
                  "unif"  = 0,
                  "hn"    = 1,
                  2) + length(model[[2]]$adj.order)
  if(meta.data$binned){
    if((length(meta.data$breaks)-1) < npars){
      stop("Number of parameters to estimate exceed number of distance bins minus 1")
    }
  }else{
    if(length(unique(data$distance)) < npars){
      stop("More parameters to estimate than unique distances")
    }
  }

  # Setup detection model
  ddfobj <- create.ddfobj(model, xmat, meta.data, control$initial)

  # pull out the initialvalues
  initialvalues <- c(ddfobj$shape$parameters, ddfobj$scale$parameters,
                     ddfobj$adjustment$parameters)
  if(!is.null(initialvalues)){
    bounds <- setbounds(control$lowerbounds, control$upperbounds,
                        initialvalues, ddfobj, meta.data$width, meta.data$left)
  }else{
    bounds <- NULL
  }

  misc.options<-list(point=meta.data$point, int.range=meta.data$int.range,
                     showit=control$showit,
                     integral.numeric=control$integral.numeric,
                     breaks=meta.data$breaks, maxiter=control$maxiter,
                     refit=control$refit, nrefits=control$nrefits,
                     parscale=control$parscale, mono=meta.data$mono,
                     mono.strict=meta.data$mono.strict, binned=meta.data$binned,
                     width=meta.data$width, standardize=control$standardize,
                     mono.points=control$mono.points, mono.tol=control$mono.tol,
                     mono.delta=control$mono.delta, debug=control$debug,
                     nofit=control$nofit, left=meta.data$left,
                     silent=control$silent,
                     mono.method = control$mono.method, # FTP: added this to specify constraint solver
                     mono.startvals = control$mono.startvals,  # FTP: find best start values or just fit with "bad" ones?
                     mono.random.start=control$mono.random.start,
                     mono.outer.iter=control$mono.outer.iter
                    )
  
  # debug - print the initial values
  if(misc.options$showit>=1 && !is.null(initialvalues)){
    cat("DEBUG: initial values =", round(initialvalues, 7), "\n")
  }

  # Note there is a difference between maxit (the maximum numbr of iterations
  # for optimx() uses) and maxiter (which is what detfct.fit uses.)
  optim.options <- list(maxit         = control$optimx.maxit,
                        optimx.method = control$optimx.method,
                        parscale      = control$parscale)

  if(is.null(initialvalues)) misc.options$nofit <- TRUE

  # Trying to use MCDS.exe but it's not there
  if(control$optimizer == "MCDS" && system.file("MCDS.exe", package="mrds") == ""){
    stop("You have chosen to use the MCDS.exe optimizer but it cannot be found!", call. = FALSE)
  }
  
  # Validate options are suitable for MCDS
  if(control$optimizer %in% c("MCDS","both") && system.file("MCDS.exe", package="mrds") != ""){
    MCDS.options.valid <- validate.MCDS.options(model)
    # If NULL there are no issues
    if(!is.null(MCDS.options.valid)){
      R.opt.message <- ifelse(control$optimizer == "MCDS",
                              "The R optimizer will be used instead.",
                              "Only the R optimizer will be used.")
      # Otherwise there are issues so use the R optimizer
      warning(paste(MCDS.options.valid, R.opt.message, sep = " "),
              immediate. = TRUE, call. = FALSE)
      control$optimizer <- "R"
    }
  }

  # run MCDS.exe if it's there
  if(control$optimizer %in% c("MCDS","both") && system.file("MCDS.exe", package="mrds")!=""){
    lt_mcds <- try(run.MCDS(model, xmat, method, meta.data, control),
                   silent=control$showit>0)
    # if something went wrong just return a very large lnl
    if(inherits(lt_mcds, "try-error")){
      lt_mcds <- list(lnl=1e100)
    }
    
  }else{
    lt_mcds <- list(lnl=1e100)
  }
  lt_mcds$value <- lt_mcds$lnl

  # do the optimisation in R
  if(control$optimizer %in% c("R","both")){
    lt <- detfct.fit(ddfobj, optim.options, bounds, misc.options)
  }else{
    lt <- list(value=1e100)
  }

  # check there is a valid lnl for at least one of the models
  # (only check if it is not in refit mode)
  if(control$optimizer %in% c("MCDS","both") && lt_mcds$lnl == 1e100 && lt$value == 1e100){
    stop("Model fitting failed", call. = FALSE)
  }
    
  # which was the better lnl?
  # if(abs(lt_mcds$lnl) < abs(lt$value)){ # FTP: old, commented out as it should not do this comparison when optimzer == 'R'
  if(abs(lt_mcds$lnl) < abs(lt$value) & control$optimizer != "R"){
    if(control$showit>=1){
      cat("DEBUG: MCDS lnl =", round(lt_mcds$value, 7),
          "       mrds lnl =", round(lt$value, 7),"\n")
    }
    lt <- lt_mcds$ds
    lt$hessian <- lt_mcds$hessian
    lt$optimise <- "MCDS.exe"
  }else{
    ## FTP: Check if the mono optimiser was used or not
    if (misc.options$mono) {
      lt$optimise <- paste0("mrds (", misc.options$mono.method, ")")
    } else {
      lt$optimise <- paste0("mrds (", control$optimx.method, ")")
    }
  }

  # check that hazard models have a reasonable scale parameter
  if(ddfobj$type=="hr" && lt$par[1] < sqrt(.Machine$double.eps)){
    warning("Estimated hazard-rate scale parameter close to 0 (on log scale). Possible problem in data (e.g., spike near zero distance).", immediate.=TRUE)
  }

  # add call and others to return values
  stored_data <- data[row.names(data) %in% row.names(xmat), ]
  stored_data$detected <- 1
  result <- list(call=call, data=stored_data, model=substitute(model),
                 meta.data=meta.data, control=control, method=method,
                 ds=lt, par=lt$par, lnl=-lt$value)

  # if there was no convergence, return the fitting object incase it's useful
  # it won't be of the correct class or have the correct elements
  if(lt$converge!=0 && misc.options$debug){
    warning("No convergence, not calculating Hessian, predicted values, abundance\nReturned object is for debugging ONLY!")
    options(save.options)
    return(result)
  }

  # 4-Jan-12 dlm sometimes this fails, so wrap it up in a try()
  if(is.null(lt$par)){
     lt$hessian <- NULL
  }else{
    result$hessian <- try(flt.var(result$ds$aux$ddfobj, misc.options))
    # Uses formula in Buckland et al or it doesn't match DISTANCE output
    # unless the result is singular
    if(inherits(result$hessian, "try-error")){
      # the hessian returned from solnp() is not what we want, warn about
      # that and don't return it
      if(misc.options$mono){
        if(control$optimizer == "R"){
          warning("First partial hessian calculation failed with monotonicity enforced, no hessian\n", immediate. = TRUE, call. = FALSE)
          result$hessian <- NULL
        }
      }else{
        if(is.null(lt$hessian)){
          # Avoid duplicate warnings
          if(control$optimizer == "R"){
            warning("First partial hessian calculation failed and second-partial hessian is NULL, no hessian\n", immediate. = TRUE, call. = FALSE)
          }
          result$hessian <- lt$hessian
        }else{
          if(control$optimizer == "R"){
            warning("First partial hessian calculation failed; using second-partial hessian\n", immediate. = TRUE, call. = FALSE)
          }
          result$hessian <- lt$hessian
        }
      }
    }else if(length(lt$par)>1){
      if(inherits(try(solve(result$hessian), silent=TRUE), "try-error")){
        if(is.null(lt$hessian)){
          # Avoid duplicate warnings
          if(control$optimizer == "R"){
            warning("First partial hessian is singular and second-partial hessian is NULL, no hessian\n", immediate. = TRUE, call. = FALSE)
          }
          result$hessian <- lt$hessian
        }else{
          if(control$optimizer == "R"){
            warning("First partial hessian is singular; using second-partial hessian\n", immediate. = TRUE, call. = FALSE)
          }
          result$hessian <- lt$hessian
        }
      }
    }
  }

  modpaste <- paste(model)
  modelvalues <- try(eval(parse(text=modpaste[2:length(modpaste)])))
  class(result$ds) <- c(modelvalues$fct, "ds")

  result$dsmodel <- modpaste

  # AIC computation
  n <- length(xmat$distance)
  npar <- length(lt$par)
  result$criterion <- 2*lt$value + 2*npar

  # give the object some class
  class(result) <- c("ds", "ddf")

  # if we have adjustments then check the monotonicity constraints
  if(!is.null(ddfobj$adjustment) & (ddfobj$type %in% c("hn", "hr", "unif"))){
    result$monotonicity.check <- check.mono(result, n.pts=control$mono.points)
  }

  if(is.null(lt$message)){
    result$ds$message <- ""
  }

  if(lt$message == "FALSE CONVERGENCE" |
     lt$message == "FALSE CONVERGENCE & UNABLE TO FIND ALTERNATIVE STARTING VALUES"){
    warning("Model fitting did not converge. Try different initial values or different model\n", immediate.=TRUE)
  }else{
    result$fitted <- predict(result, esw=FALSE)$fitted
    if(control$estimate){
      result$Nhat <- NCovered(result, group=TRUE)
    }
  }
  
  # Store optimiser
  result$optimise <- lt$optimise

  # Restore user options
  options(save.options)

  return(result)
}
