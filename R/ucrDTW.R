#' ucrDTW
#'
#' \code{ucrDTW} Finds the K-NN of a query in a reference vector. 
#'
#' The function preforms a K nearest neighbors search of a query within a
#' reference vector and was wholly adapted from the University of California
#' Riverside's 'UCR Suite.' Understanding the first generalization, allowing K >
#' 1 starts with looking at the variables K and jumpSize.  Setting jumpSize = 1
#' and K = 1 should provide results equal to the original software, while
#' setting K > 1 gives the nearest neighbors regardless of its location relative
#' to the last update. The default and more useful setting is leaving jumpSize
#' NULL which is equivalent to setting jumpSize equal to the length of the
#' query.  This will take the difference of each update candidate's current
#' location and the location of the last NN found. If it is less than jumpSize
#' we update the current set only if it improves the last NN, i.e. replacing the
#' last NN with the current candidate. Otherwise we check to see of the distance
#' is less than the 'worst of the current K-NN.'
#'
#' The second generalization provided is the addition of the depth parameter.
#' depth can be set as an integer from 1 to 4 with 4 being the default, a full
#' dynamic time warping search. Setting Depth = 1 computes only the
#' lower_bound_Kim distance measure; Depth = 2 computes the lower_bound_Keogh
#' distance using an envelope around the query; and Depth = 3 uses the minimum
#' of the LB_Keogh (depth==2) and a LB_KEogh with the envelope around the
#' reference data. This can be used for quickly extracting a K length index of the reference 
#’ set to be used with other data analysis routines.   
#' 
#' The distance used is Euclidean without the sqrt() calculation ie (x-y)^2.
#' Infinity is 1e20 for this function.
#'
#' For detailed information see
#' \url{http://www.cs.ucr.edu/~eamonn/UCRsuite.html}.

#' @author William Pleasant wholly adapted from UCR Suite
#' \url{http://www.cs.ucr.edu/~eamonn/UCRsuite.html}

#' @param query A 1-d numeric vector searched for in reference.
#'
#' @param reference A 1d numeric vector reference data with length >= that of
#' the query.
#'
#' @param win An integer for determining the window size for the upper and
#' lower bounds.  @param K  A scalar integer to determine the number of  nearest
#' neighbors to search for.
#'
#' @param jumpSize  An integer, see details.
#'
#' @param depth     An integer within 1:4, see details.
#'
#' @param sortNN    TRUE/FALSE  determining if the return arguments should be
#' sorted.
#'
#' @param epoch     A integer determining the the amount of data that can
#' be processed before refreshing the mean and sd variables internally. Only
#' provided here for completeness.
#'
#' @param verbose   TRUE/FALSE provided to print the efficiency of each step
#' in the filtering process.
#'
#' @param naCheck  TRUE/FALSE which if set to true returns an error if there
#' are any NAs in the data. Defaults to FALSE.  

#'  @examples 
#'
#'  set.seed(1001)
#'  K         <- 5 
#'  win       <- 100
#'  loc       <- 50000
#'  loc2      <- 25000
#'  reference <- arima.sim(list(ar=c(.95)),n=100000)
#'  
#'  query <- reference[seq_len(win)+loc]
#'  
#'  ## add noise to reference locations.  
#'  reference[seq_len(win)+loc] <- query+runif(win,-.5,.5)
#'  reference[seq_len(win)+loc2] <- query+runif(win,-1.,1)
#'  
#'  out <-  ucrDTW(query,reference,win,K)
#'  out
#'  
#'  m <- sapply(seq_len(K), function(i) reference[seq_len(win)+out$location[i]])
#'  
#'  matplot(cbind(query,m),,'l')


#' @return 
#' \code{ucrDTW} a list consisting of 
#'  \item{distance:}{ A numeric vector the K distances requested.}
#'  \item{location:}{ An integer vector of the  K starting locations for each distance.}
#'
#' @references Rakthanmanon, Thanawin, et al. "Searching and mining trillions
#' of time series subsequences under dynamic time warping." Proceedings of the
#' 18th ACM SIGKDD international conference on Knowledge discovery and data
#' mining. ACM, 2012.



ucrDTW <- function(query,reference, win=length(query), K=1L, epoch=100000L,
                   sortNN=TRUE, jumpSize=NULL, depth=4L, verbose=FALSE, naCheck=FALSE)
{
  if(naCheck){
    if(anyNA(query))     stop("NAs in query \n")
    if(anyNA(reference)) stop("NAs in reference \n")
  }
  if(is.null(jumpSize)) jumpSize <- if(K>1L){ length(query) } else { 1L }
  .Call(ucr_dtw_knn_C,query,reference, as.double(win)
        ,K,epoch ,sortNN, jumpSize, depth,verbose)
}


