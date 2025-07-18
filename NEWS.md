# mrds 3.0.1

Bug Fixes

* Fixed formatting issue in flnl.grad help
* Fixed output for gof test when degrees of freedom for MR models is <= 0 (Issue #96)
* Now displays a warning if the user tries to fit a detection function with covariates using MCDS.exe which is not either a half-normal or a hazard rate model. (Issue #113)
* Fixed so that the MCDS.exe does not try to fit a negative exponential in place of a gamme key function. (Issue #113)
* Now issues warnings when there is only a single transect and varflag option is 1 or 2. (Issue #115)
* No longer plots data points on detection functions for binned analyses, only shows the interval bins.
* Add a check and a warning when the object field of the obs.table is not numeric. (Distance Issue #165)


Enhancements

* Documentation of dht.se to show variance calculations for varflag options (Issue #117)
* Modified the bysample table returned from dht (Issues #60 and #100)
* Clarified documentation regarding summary table output from dht.

# mrds 3.0.0

New features

* The default R optimiser when (strict) monotonicity of the detection function is enforced has been improved. Monotonicity is enforced only when the detection function has adjustment terms but does not include covariates. The new optimiser is a Sequential Least Squares Programming (SLSQP) algorithm included in the 'nloptr'-package. This optimiser uses analytical gradients rather than approximate gradients and is therefore more robust and has improved runtime. Users can still make ddf() use the previous default R optimiser by specifying mono.method = 'solnp' in the 'control' argument. The default for mono.method is 'slsqp'. Because of this and other small improvements and bug fixes in the monotonic optimiser, results from ddf() might change even when using the old solnp optimiser. In most cases, however, we do not expect significant changes in the estimates. 

Bug Fixes

* The summary of the fitting object now correctly prints the optimiser used when monotonicity is enforced ('slsqp' or 'solnp'). 
* check.mono() now uses the same point locations as the optimiser. It also uses the same tolerance as the optimiser (1e-8) and applies this tolerance when checking (strict) monotonicity, and when checking 0 <= g(x) <= 1.

# mrds 2.3.0

New Features

* The 'P2' estimator is now the default for estimating the encounter rate variance for point transect surveys. (Issue #65)

Bug Fixes

* Re-formatted the format section of the documentation for the book.tee.data (Issue #91)
* Ensure that the MCDS optimizer is not used for double observer models as this was generating errors. (Issue #89)
* Improved the documentation on initial values, lower and upper bounds in both the ddf and mrds_opt documentation (mrds_opt was renamed from mrds-opt which was not accessible via ?mrds-opt). (Issue #90)

# mrds 2.2.9

New Features

* Users can now download the fortran MCDS.exe optimiser used in Distance for Windows and fit single observer models with both the optimisers in R via # mrds and also MCDS.exe. For some datasets the optimisation with MCDS.exe is superior (giving a better likelihood) than the optimiser in R used with mrds. See ?MCDS for more details.

Bug Fixes

* fix bug where the (true, 2nd derivative) hessian was not calculated during optimisation. This then lead to weird errors later (summary doesn't work etc). Hessians are now calculated in this case. Thanks to Anne Provencher St-Pierre for reporting the issue
* Fix prediction bug (Issue #84) where predicting for hazard rate model with covariates and se.fit= TRUE. Note there may be issues when predicting in this instance for binned data - check results are as expected.
* Fix bug when a uniform model was fitted with no adjustments. This caused an error when looking for the hessian. It also required that the covariance set to 0 when estimating the cluster size standard errors (Issue #79).
* fix bug with using binned data via cutpoints for prediction (#73)

# mrds 2.2.8

* Fix bug where plotting rem.fi models when truncation was used would lead to an error being thrown. (#58)
* Fix bugs when a uniform is fitted with no adjustments (#59)
* Fix bug in plotting when left truncation was used and points didn't match detection function line (Distance #134)
* Fix bug in debug reporting when uniform only models are used (Distance #136)
* Fix bug in adjustment term fitting where width scaling was defined as right minus left truncation, rather than just the right truncation value (Distance #133)
* Use (0,width) as the interval for monotonicity checks, rather than (left, width) as this was causing issues and is not consistent with Distance for Windows (Distance #135)
* Expose mono.outer.iter option to control number of outer iterations used to fit a monotonic model. Default 200.
* Make dht output tables consistent. Now always refers to Region in the display (rather than Region in summary and Label in N/D tables). Note this is only a display change so won't break code which looks to extract these values based on column names from the dht object which is unchanged.
* Fixed bug leading to erroneous zero totals in individuals N/D tables when there were no sightings in one or more strata. Bug was apparent when the data were sightings of clusters and the varflag 1 option (er_method = 1 in Distance ds function) was selected in the dht function.

# mrds 2.2.7

* Fix bug in check for # parameters < # data. Thanks to Anne Provencher St-Pierre.
* No longer display errors caused by solnp/gosolnp when doing constrained optimisation, these can be seen when showit>0 if necessary.
* EXPERIMENTAL change to use fixed grid starting values when using monotonicity constraints, set control$mono.random.start=TRUE to get old behaviour
* Scale covariates absolutely rather than relatively during optimisation.
* Expected.S element of dht return now a data.frame not a list
* Fix total encounter rate and its variance in stratified analysis

# mrds 2.2.6

* Individuals summary table for dht now includes k (number of transects)
* Add effective detection radius (EDR) and its uncertainty to summary output
* Change default rounding of chi-squared test tables. This can be customized using print(ddf.gof(...), digits=?) for e.g., printing with knitr::kable
* New detection function: two-part normal ("tpn"), useful for aerial surveys in mountainous terrain, see Becker EF, Christ AM (2015) A Unimodal Model for Double Observer Distance Sampling Surveys. PLOS ONE 10(8): e0136403. https://doi.org/10.1371/journal.pone.0136403 and ?"two-part-normal".
* To improve consistency in functions and arguments in the package, some functions will change from . separation to _. For now both versions exist but will be removed in # mrds 2.2.7.
  - add_df_covar_line -> add.df.covar.line
  - p_dist_table -> p.dist.table
* Variable strip widths are now supported in dht. Users should supply an additional column to the sample data.frame ("CoveredArea") giving the total area covered in the given transect and set options=list(areas.supplied=TRUE). Thanks to Megan Ferguson for providing an example, code and feedback.

# mrds 2.2.5

* use "probabalists" definition of Hermite polynomials, as from Distance. More numerically stable
* remove setting of Hermite parameter to 1 (unclear why this was the case!)
* refinement of adjustment-key-all outer optimisation, optimization is now only over the subset of parameters, rather than holding one parameter constant
* refine outer optimization, using best previous values (by likelihood) rather than last values. Use optimizer's convergence diagnostic to assess outer convergence.
* Refinement of "inner" optimization (detfct.fit.opt): (1) simplification of stopping rules (one while() loop rather than two), (2) parameters are nudged only when bounds have not been hit, if bounds have   been hit then they are expanded
* Rescaling of covariate models' parameters (when scaling difference was large) was inverted, causing all kinds of issues.
* Made the scaling kick-in at smaller scales.
* Removed inner (detfct.fit.opt) while() loop dependence on bounded status, since that didn't seem to make sense
* Stop "correcting" infinite/NaN integrals to small numbers as this was misleading the optimizer to think these were "good" values
* Refine constrained optimisation to use actual starting values once, then use random start points and compare the two.
* handle the case where a model failed in AIC adjustment term selection, montonicity check would throw an error
* assign g(x)=0 for g(x)<0 when integrating the detection function (but check post-optimisation that this is not a problem!)
* fix bug in predict.ds when uniform key was used with binned data (Thanks to Noémie Cappelle for reporting this issue!)
* dht now prints additional information about the variance estimators used
* errors now thrown when more parameters than data (either unique distance values or bins)


# mrds 2.2.4

* add_df_covar_line now plots probability density functions for the point transect case
* warning is no longer raised when truncation is not set but bins are specified for binned data (it's assumed that the furthest cutpoint is the truncation)
* AIC/logLik functions now work for all methods

# mrds 2.2.3

* fix bug where region areas were not duplicated properly when density was estimated (using Area=0 in data)
* fix a bug in getting starting values for hazard-rate detection functions when point transect data is used
* fix issue with left truncation when estimating abundance/density in dht

# mrds 2.2.2

* fix issue in predict() when uniform key functions are used with new data.
* new function p_dist_table() to show the distribution of estimated probabilities of detection. Useful for covariate models to determine issues with very small ps.
* new function add_df_covar_line(), which can be used to add lines plots showing the detection function for a given covariate combination. Thanks to various members of the distance sampling mailing list for this suggestion.
* plots produced by plot.ds/plot.rem/plot.rem.fi/plot.trial/plot.trial.fi/plot.io/plot.io.fi/plot.det.tables now use same defaults as R 4.0.0 ("lightgrey" bars for histograms). Some deprecated arguments to plot.ds were removed.

# mrds 2.2.1

* hessian now returned when solnp (constrained optimisation) is used to fit the detection function
* Check for NA covariate values, thanks to Ana Cañadas for highlighting this issue.
* enable P2 variance estimator for points
* Corrected handling of NA covariates
* new option se.fit for predict.ds to obtain standard errors for the probability of detection or ESW
* Fixed a bug in dht when left truncation is used. Previously left truncation was ignored. See https://github.com/DistanceDevelopment/mrds/issues/22 thanks to Carl Schwarz for finding this bug.
* Fix bug where two objects could have a missing observer and no error was thrown. Thanks to Ainars Aunins for reporting this bug and Eric Rexstad for diagnosing.

# mrds 2.2.0

* fixed bug in calculation of Kolmogorov-Smirnov p-values. Previous methods did not take into account that parameters of the detection function were estimated, so a new bootstrap-based approach has been implemented. As this is time-consuming, the Kolmogorov-Smirnov test is no longer performed by default (use ks=TRUE to get the test).
* Encounter rate variance for point transects when points were not all sampled an equal number of times was incorrect. # mrds now uses the P3 estimator from Fewster et al (2009) for point transect encounter rate variance.
* Bug in predicting when left truncation is used. Previously if the distance column in the new data was set to zero and left truncation was > 0 predictions were discarded, this was particularly problematic for io, etc # mrds models. Thanks to Natalie Kelly for spotting this and suggesting a fix.
* Add errors when "P3" is used as an encounter rate variance estimator with non-point transect data, throws a warning and switches to P3 for points when it's not specified.

# mrds 2.1.18

* fixed bug in parameter rescaling where scales were incorrectly entered as 1 due to an indexing bug
* Quantile-quantile plots now use an aspect ratio of 1
* Bug in half-normal integration code when no adjustments are used lead to likelohood being evaluated incorrectly for models with binned (grouped) distances. This only effected AIC comparisons between models and parameter estimates should have been the same. Thanks to Olivier Devineau for spotting this!
* Fix bug where predict.ds() didn't work with uniform keys. Thanks to Jason Roberts for reporting this bug.
* Correctly specify distbegin/distend for predictions with binned data, thanks to Jason Roberts for spotting this bug.
* Let the user know that int.range was set in summary() results

# mrds 2.1.17

* fixed starting value bug for hazard-rate models when distances are binned. Thanks to Natalia Schroeder and Eric Rexstad for discovering this.
* predict.ds now uses numerical integration to calculate integrals (rather than an approximation). Thanks to Eric Rexstad for spotting an issue with goodness of fit testing that highlighted this.
* plot.ds() now accepts an xlab="" argument to change the x axis label. Thanks to Steve Ahlswede for suggesting this.

# mrds 2.1.16

* improved predict() method now does the Right Thing with factors
* Fixed bug in scaling of histograms for point transect pdf plots and points on those plots. Thanks to Erics Howe and Rexstad for reporting these issues.
* You can now set y axis limits when using plot.ds, defaults should be more sensible for pt+point models. Thanks to Eric Howe for the suggestion.
* Fixed bug when setting initial values that threw many errors. Thanks to Laura Marshall for spotting this.

# mrds 2.1.15

* rescaling parameters were not correct, now fixed. Thanks to Laura Marshall for spotting this.
* coefficients are called coefficients (not a mixture of coefficients and parameters) in summary() results
* speed-up in io.fi models (thanks to Winston Chang's profvis, showing many unnecessary calls to model.matrix)
* plot.ds now has a pdf= option to plot the probability density function (for point transect models only)
* assign.par, create.ddfobj and detfct are now exported, so it can be used by dsm (though shouldn't be used by anything else!)
* fixed bug in left truncation where probability of detection was not calculated correctly. Thanks to Jason Roberts for pointing this out!

# mrds 2.1.14

* updated initialvalues calculation for hazard-rate -- now uses Beavers & Ramsay method to scale parameters for hazard-rate
* automatic parameter rescaling for covariate models when covariates are poorly scaled. Now default for nlminb method
* minor speed-up to logistic code when distance is a covariate


# mrds 2.1.13

* link to distance sampling Google Groups in help
* duplicate non-convergence warning/error removed
* warning of singular Hessian is now a warning()
* re-wrote the debug output to be easier to read
* dht now has an option (ci.width) to specify confidence interval width in output (thanks to David Pavlacky for the suggestion)
* monotonicity now operates over left->right truncation for models that are left truncated and will fail with an error message if many integration intervals are used. Thanks to Tiago Marques for highlighting this issue.

# mrds 2.1.12

* \donttest{} examples are now \dontrun{}.

# mrds 2.1.11

* Bug in unif+cos(1) models when using monotonicity constraints and randomised starting points. Since the model only has 1 parameter, there is a bug in selecting columns in Rsolnp starting value code that makes the result be a vector, which then doesn't work with an apply later. Workaround of not using randomised starting values in # mrds for that model. Thanks to Nathalie Cavada for finding this bug.
* Fixed bug in pdot.dsr.integrate.logistic which was giving incorrect AIC values for FI models with binned data for points or lines.
* Fixed issue where returned optimisation obejct got accessed without being checked to see if it's result was an error, causing problems when encapsulating ddf in other functions.


# mrds 2.1.10

* added testing directory to .Rbuildignore, tests are now not included in built packages and are not run on CRAN. For tests use the source packages on github.


# mrds 2.1.9

BUG FIXES

* removed test that failed on CRAN's testing

# mrds 2.1.8

CHANGES
* removed doeachint/cgftab code, which used a spline approximation to the effective strip width/effective area when a half-normal detection function was used. This has been replaced with exact calculation via the error function (erf).
* tests updated accordingly
* monotonically constrained models now use a bunch of random start points -- uses gosolnp() from Rsolnp
* re-fitting by jiggling parameters refined to multiply by a uniform variable with limits set as the upper and lower bounds (+/-1) so jiggling can go either way, on approximately the same scale as the parameters
* corrected documentation for predict methods, which incorrectly stated what is returned for point transect models. Thanks to Thibault Dieuleveut for spotting this.

BUG FIXES

* fixed 2 bugs in create.varstructure; the first was for removal method which was being treated as a trial method. The second was when obs.table was not specified (Region and sample labels in dataframe for each obs) and there was dual observers. In that case it was doubling the number of observations.
* fixed a bug in dht.deriv which had not been setup for removal; thanks to John Boulanger for noticing and reporting both of these bugs

# mrds 2.1.7

BUG FIXES

* Standardisation was being applied to detection functions (such that g(0)=1) when there were no adjustments (which is unnecessary) but also caused issues when using gamma detection functions as this should be calculated at g(apex) instead. Standardisation code has been removed for when there are no adjustments and the correct scaling used for the gamma when there are. Thanks to Thomas Doniol-Valcroze for alerting us to this bug.
* Partial name-matching in dht was fixed. Produced warning but not error.

NEW FEATURES

* Tests for gamma detection functions
* Observations are automatically ordered by object and observer fields (if included) in ddf as expected by double observer analysis. A erroneous error message can be created if they are not ordered correctly or worse. Thanks to Ainars Aunins for bringing this to our attention.
* Added function create_document() which will run a shiny application interface to # mrds and will create a knitr document from a template. The template currently is only for a single observer analysis and is behind on all of the features for the app which is fairly complete. 

# mrds 2.1.6

BUG FIXES

* some key+adjustment models failed to converge due to bugs in the optimisation code (mainly unif+cosine models)

NEW FEATURES

* optimisation tips help page at ?"mrds-opt"

# mrds 2.1.5

CHANGES
* models with both adjustment terms and covariates are now allowed
* mono.check function checks that a detection function is monotonic over its range (at the observed covariate combinations if covariates are included)

# mrds 2.1.4-5

CHANGES

* new `testthat` changes test locations etc, this has been sorted out.
* which= argument in plot.* now sorts the which first, so plots will always be in order
* plot.ds is now more friendly to par() users, thanks to Jason Roberts for the pointer

BUG FIXES

* uniform+cosine detection functions were ignored when using monotonicity constraints, now they can be used together
* mono.strict=TRUE didn't automatically turn on mono=TRUE, extra logic to correct this
* montonicity constraints did not use standardised (g(x)/g(0) detection functions, so if g(x)>1 monotonicity constraints were violated. Now standardised detection functions are used. Thanks to Len Thomas for noticing this bug.

# mrds 2.1.4-3

BUG FIX

* predict.io.fi did not work for new data (thanks to Len Thomas and Phil Hammond for pointing this out)

CHANGES

* general documentation updates
* simplification and re-structuring of internals

# mrds 2.1.4-3

CHANGES

* internal re-structuring of summary methods
* more tests

# mrds 2.1.4-2

CHANGES

* plot.ds now has a new argument, if TRUE (default) it will create a new window for each plot.
* general janitorial work inside plotting methods, removing and simplifying old code; (hopefully) no new features.

# mrds 2.1.4-1

CHANGES

* Warning now issued when truncation is set to the largest distance by default.
* updated dht documentation


# mrds 2.1.4

CHANGES

* modified det.tables and plot.det.tables so it does not create and plot some tables depending on observer configuration (io,trial,removal).
* to plot functions (other than plot.ds) added argument subtitle=TRUE (default). It can be either TRUE, FALSE. If TRUE it shows sub-titles for plot type. If FALSE, no subtitles are shown. With this argument it is possible to get subtitles without main title. 
* set iterlimit=1 in call to rem.glm from ddf.rem.fi to prevent convergence issues in getting starting values. 
* created average.line.cond and it is now used in place of calcp.# mrds which was computing average line for conditional detection function by weighting values by estimated population proportions for each covariate value. It is now weighted by sample proportions (mean value). 

# mrds 2.1.3-1

BUG FIXES

* patched dht.se so if vc1=NA it will not fail
* patched plot.ds to only issue dev.new when not using another graphics device so it plays nice with Distance.

# mrds 2.1.3

BUG FIXES

* patched bug in dht which was returning incorrect values in bysample for sample.area and Dhat.
* patched code in dht.se so it would skip over variance component for p when key=unif and p=1.

CHANGES

* modified code in detfct.fit.opt and io and rem functions to adapt to changes in optimx
* removed old depends statements to optimx and Rsolnp; uses import

# mrds 2.1.2

BUG FIXES

* fixed usage and example lines that were too long

# mrds 2.1.1

BUG FIXES

* for full independence methods, the calculation for the distance sampling component was for unbinned data only. Code has been added to compute this component correctly for binned data. This required changes to each of the ddf.x.fi routines and for the logistic integration routines.

CHANGES

* Modified flpt.lnl code to set integrals to 1E-25 if <=0 
* In integrate.pdf a vector argument for the integration range is converted to matrix if of length 2.
* ddf.gof will now use breaks set for binned data unless others are specified.


NEW FEATURES

* Added threshold detection functions ("th1" and "th2") which required some minor changes in other functions for summary/print.
* Added xlab and ylab arguments to plot functions to over-ride default labels

# mrds 2.1.0

CHANGES

* Modified DESCRIPTION so only R 2.15 or greater is allowed. Needed for optimHess jll(12/10/2012)

# mrds 2.0.9

NEW FEATURES

* New option plot=TRUE/FALSE in qqplot.ddf(), for when you only want the K-S and CvM test statistics, not plotting. dlm(11/13/2012)

BUG FIXES

* Fixed problem when obs dataframe in call to dht (which links observations to samples and regions) contained fields also in observation dataframe. Now only fields needed from obs are selected before merge. dlm(11/13/2012)

# mrds 2.0.8

* Unchanged version sent out with Distance in summer 2012

# mrds 2.0.7

NEW FEATURES

* Restructured likelihood/integration code for fitting ds models
* Adjustment functions will now work with binned data. Code was added to assure that fields distbegin and distend are available if binned=TRUE and breaks are set as well.
* Added argument adj.exp which if set to TRUE will use key*exp(adj) rather than key*adj to keep f(x)>0
* Added following restrictions for adjustments: if uniform key, adj.scale must be "width"; if non-uniform key and adj.scale="width", doeachint set to TRUE because scale integration will not work.
* Changed code in several functions so a uniform key with no adjustment functions could be used.
* New option plot=TRUE/FALSE in qqplot.ddf(), for when you only want the K-S and CvM test statistics, not plotting.

BUG FIXES

* Fixed inconsistencies in use and documentation of showit argument
* Fixed a bug where groups were not recognised in dht() when the size column occurred in both model data and observation table. (Thanks to Darren Kidney for spotting this.)


# mrds 2.0.6

NEW FEATURES

* Example code for binned point count data added to help for ddf
* Modified ddf.rem.fi and ddf.io.fi to use starting values from iterative offset glm to make optimization more robust
* Added a restriction so no one attempts fitting adjustment functions with covariates.
* Added some code to assure all of the necessary fields are available for binned data (binned=TRUE).

BUG FIXES

* Patched create.ddfobj so that point counts with binned data would work properly
* Patched ddf.ds such that stored data in object$data has detected=1
* Patched ddf.io.fi to throw an error when optimx() does not converge
* Patched ddf.io.fi and ddf.rem.fi so inclusion of factor(observer) will work in formula
* Patched dht, dht.se and covered.region.dht so it would handle 0 observations
* Suppress package messages from optimx
* Patched fpt.lnl, flt.lnl, print.ddf, model.description, summary.ds, print.summary.ds and coef.io, coef.trial, coef.rem, plot.io, plot.trial, and plot.rem to handle uniform key function.


# mrds 2.0.5

NEW FEATURES

* First version submitted to CRAN

BUG FIXES

* Fixed code in dht.se such that it uses sample size from detection model in Satterthwaite approximation rather than size of selected subset of observations.
* Fixed coef functions so they would return parameter estimates for adjustment functions if any.

# mrds 2.0.4

BUG FIXES

* Changed flt.var to compute variance of average p correctly for point transects.
* Numerous changes by dlm to optimization code
* Changes to documentation to remove non-ASCII characters

# mrds 2.0.3

NEW FEATURES

* Major rewrite to ddf and summary functions to handle adjustment functions

BUG FIXES

* Changes to det.tables and gof functions to use include.lowest=TRUE in calls to cut function
* Changed all usage of T and F to TRUE and FALSE 


# mrds 2.0.2

* For changes in 2.0.2 and earlier see ONEWS
