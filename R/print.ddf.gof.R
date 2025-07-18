#' Prints results of goodness of fit tests for detection functions
#'
#' Provides formatted output for results of goodness of fit tests: chi-square,
#' Kolmogorv-Smirnov and Cramer-von Mises test as appropriate.
#'
#' @method print ddf.gof
#' @param x result of call to \code{\link{ddf.gof}}
#' @param \dots unused unspecified arguments for generic print
#' @param digits number of digits to round chi-squared table values to
#' @export
#' @return None
#' @author Jeff Laake
#' @seealso \code{\link{ddf.gof}}
#' @keywords utility
print.ddf.gof <- function(x, digits=3, ...){

  chitable <- function(observed, expected, digits){
    x <- rbind(observed, expected, (observed-expected)^2/expected)
    x <- cbind(x, apply(x, 1, sum))
    colnames(x)[dim(x)[2]] <- "Total"
    rownames(x) <- c("Observed", "Expected", "Chisquare")
    x <- as.data.frame(round(x, digits=digits))
    x <- format.data.frame(x, scientific=FALSE)
    return(x)
  }

  gof <- x
  cat("\nGoodness of fit results for ddf object\n")

  if(!is.null(gof$chisquare)){
    cat("\nChi-square tests\n")

    # This is NULL when it is a single observer model
    if(!is.null(gof$chisquare$chi2)){
      cat("\nDistance sampling component:\n")
    }

    print(chitable(gof$chisquare$chi1$observed, gof$chisquare$chi1$expected, digits))

    if(!is.na(gof$chisquare$chi1$p)){
      cat(paste("\nP = ", format(gof$chisquare$chi1$p, digits=5),
                " with ", gof$chisquare$chi1$df," degrees of freedom\n",sep=""))
    }else{
      cat("\nNo degrees of freedom for test\n")
    }

    if(!is.null(gof$chisquare$chi2)){
      if(dim(gof$chisquare$chi2$observed)[1]==3){
        Trial <- FALSE
      }else{
        Trial <- TRUE
      }

      cat("\nMark-recapture component:\n")

      if(Trial){
        cat("Capture History 01\n")
      }else{
        cat("Capture History 10\n")
      }

      print(chitable(gof$chisquare$chi2$observed[1, ],
                     gof$chisquare$chi2$expected[1, ]))

      if(Trial){
        cat("Capture History 11\n")
      }else{
        cat("Capture History 01\n")
      }

      print(chitable(gof$chisquare$chi2$observed[2, ],
                     gof$chisquare$chi2$expected[2, ]))

      if(!Trial){
        cat("Capture History 11\n")
        print(chitable(gof$chisquare$chi2$observed[3, ],
                       gof$chisquare$chi2$expected[3, ]))
      }

      if(!is.na(gof$chisquare$chi2$p)){
        cat(paste("\nMR total chi-square = ",
                  format(gof$chisquare$chi2$chisq, digits=5),
                  "  P = ", format(gof$chisquare$chi2$p, digits=5),
                  " with ", gof$chisquare$chi2$df,
                  " degrees of freedom\n", sep=""))
      }
      
      if(!is.na(gof$chisquare$pooled.chi$p)){
        cat(paste("\n\nTotal chi-square = ",
                  format(gof$chisquare$pooled.chi$chisq, digits=5),
                  "  P = ", format(gof$chisquare$pooled.chi$p, digits=5),
                  " with ", gof$chisquare$pooled.chi$df, " degrees of freedom\n",
                  sep=""))
      }else{
        cat("\nTotal chi-square: No degrees of freedom for test\n")
      }
      
    }
  }

  if(!is.null(gof$dsgof)){
    if(!is.na(gof$dsgof$ks$Dn)){
      cat("\nDistance sampling Kolmogorov-Smirnov test\n")
      cat("Test statistic = ", format(gof$dsgof$ks$Dn, digits=6),
          " p-value = ", format(gof$dsgof$ks$p, digits=6), "\n", 
          " (p-value calculated from ",gof$dsgof$boot_success, "/",
             gof$dsgof$nboot, " bootstraps)", sep="")
    }
      cat("\nDistance sampling Cramer-von Mises test (unweighted)\n", sep="")
      cat("Test statistic = ", format(gof$dsgof$CvM$W, digits=6),
          " p-value = ", format(gof$dsgof$CvM$p, digits=6), "\n", sep="")
  }

  invisible()
}
